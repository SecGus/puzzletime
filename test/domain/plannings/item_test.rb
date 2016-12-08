# encoding: utf-8

require 'test_helper'

class PlanningItemTest < ActiveSupport::TestCase
  test 'with definitive planning' do
    p1 = Planning.create!(employee_id: employees(:pascal).id,
                          work_item_id: work_items(:puzzletime).id,
                          date: '2000-01-03',
                          percent: 50,
                          definitive: true)

    i = Plannings::Item.new
    i.planning = p1

    expected = {
      class: '-definitive -percent-50',
      title: nil,
      :"data-id" => p1.id
    }

    assert i.day_attrs == expected
    assert i.to_s == '50'
  end

  test 'with provisional planning' do
    p1 = Planning.create!(employee_id: employees(:pascal).id,
                          work_item_id: work_items(:puzzletime).id,
                          date: '2000-01-03',
                          percent: 70,
                          definitive: false)

    i = Plannings::Item.new
    i.planning = p1

    expected = {
      class: '-provisional -percent-70',
      title: nil,
      :"data-id" => p1.id
    }

    assert i.day_attrs == expected
    assert i.to_s == '70'
  end

  test 'with rounded percentage planning' do
    p1 = Planning.create!(employee_id: employees(:pascal).id,
                          work_item_id: work_items(:puzzletime).id,
                          date: '2000-01-03',
                          percent: 75,
                          definitive: false)

    i = Plannings::Item.new
    i.planning = p1

    expected = {
      class: '-provisional -percent-80',
      title: nil,
      :"data-id" => p1.id
    }

    assert i.day_attrs == expected
    assert i.to_s == '75'
  end

  test 'with absence' do
    a1 = Absencetime.create!(work_date: '2000-01-03',
                             hours: 40,
                             employee_id: employees(:pascal).id,
                             absence: absences(:vacation))

    i = Plannings::Item.new
    i.absencetime = a1

    expected = {
      class: '-absence',
      title: 'Ferien: 40.0'
    }

    assert i.day_attrs == expected
    assert i.to_s == ''
  end

  test 'with unpaid absence' do
    a1 = Absencetime.create!(work_date: '2000-01-03',
                             hours: 40,
                             employee_id: employees(:pascal).id,
                             absence: absences(:compensation))

    i = Plannings::Item.new
    i.absencetime = a1

    expected = {
      class: '-absence -absence-unpaid',
      title: 'Überzeitkompensation: 40.0'
    }

    assert i.day_attrs == expected
    assert i.to_s == ''
  end

  test 'with planning and absence' do
    p1 = Planning.create!(employee_id: employees(:pascal).id,
                          work_item_id: work_items(:puzzletime).id,
                          date: '2000-01-03',
                          percent: 70,
                          definitive: false)

    a1 = Absencetime.create!(work_date: '2000-01-03',
                             hours: 40,
                             employee_id: employees(:pascal).id,
                             absence: absences(:vacation))

    i = Plannings::Item.new
    i.planning = p1
    i.absencetime = a1

    expected = {
      class: '-provisional -percent-70 -absence',
      title: 'Ferien: 40.0',
      :"data-id" => p1.id
    }

    assert i.day_attrs == expected
    assert i.to_s == '70'
  end

  test 'with holiday without must hours' do
    h1 = holidays(:pfingstmontag)

    i = Plannings::Item.new
    i.holiday = [h1.holiday_date, h1.musthours_day]

    expected = {
      class: '-holiday',
      title: 'Feiertag: Keine muss Stunden'
    }

    assert i.day_attrs == expected
    assert i.to_s == ''
  end

  test 'with holiday with must hours' do
    h1 = holidays(:zibelemaerit)

    i = Plannings::Item.new
    i.holiday = [h1.holiday_date, h1.musthours_day]

    expected = {
      class: '-holiday',
      title: 'Feiertag: 6.0 Muss Stunden'
    }

    assert i.day_attrs == expected
    assert i.to_s == ''
  end
end
