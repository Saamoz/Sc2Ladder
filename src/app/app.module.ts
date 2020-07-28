import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import {RankingTableComponent} from './ranking-table/ranking-table.component'

@NgModule({
  declarations: [RankingTableComponent],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [RankingTableComponent]
})
export class AppModule { }
