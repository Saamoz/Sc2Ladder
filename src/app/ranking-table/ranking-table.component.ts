import { Component } from '@angular/core';
import {players} from "../../backend/player_stats";

@Component({
  selector: 'app-ranking-table',
  templateUrl: './ranking-table.component.html',
  styleUrls: ['./ranking-table.component.css']
})
export class RankingTableComponent {
  players = players;
}
