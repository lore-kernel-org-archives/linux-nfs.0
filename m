Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:26872 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932752AbcFOOsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:48:03 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/12] NFS: Don't hold the inode lock across fsync()
Date: Wed, 15 Jun 2016 14:47:55 +0000
Message-ID: <D6D08D10-6752-4A7A-9CFE-3227D9A58BA2@primarydata.com>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <20160615070840.GA4318@infradead.org>
In-Reply-To: <20160615070840.GA4318@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTUvMTYsIDAzOjA4LCAibGludXgtbmZzLW93bmVyQHZnZXIua2VybmVsLm9yZyBv
biBiZWhhbGYgb2YgQ2hyaXN0b3BoIEhlbGx3aWciIDxsaW51eC1uZnMtb3duZXJAdmdlci5rZXJu
ZWwub3JnIG9uIGJlaGFsZiBvZiBoY2hAaW5mcmFkZWFkLm9yZz4gd3JvdGU6DQoNCj5PbiBUdWUs
IEp1biAxNCwgMjAxNiBhdCAwMzowNTowOVBNIC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+PiBDb21taXRzIGFyZSBubyBsb25nZXIgcmVxdWlyZWQgdG8gYmUgc2VyaWFsaXNlZC4NCj4N
Cj5CdXQgd2UgbmVlZCBzb21ldGhpbmcgdG8gbG9jayBvdXQgbmV3IGNhbGxlcnMgb2YgaW5vZGVf
ZGlvX2VuZA0KPndoZW4gY2FsbGluZyBpbm9kZV9kaW9fd2FpdC4gIFRoZW4gYWdhaW4gdGhlIGN1
cnJlbnQgY29kZSBhbHJlYWR5DQo+ZmFpbHMgdG8gdG8gZG8gdGhhdC4uDQoNCldlIGNvdWxkIGRv
IHRoYXQgYnkgc2V0dGluZyB0aGUgSS9PIG1vZGUgdG8gYnVmZmVyZWQ7IHRoYXQgc3RpbGwgYWxs
b3dzIHBhcmFsbGVsaXNtICBmb3IgdGhlIGJ1ZmZlcmVkIEkvTyBjYXNlLiBJIHdvdWxkbuKAmXQg
bm9ybWFsbHkgZXhwZWN0IGFwcGxpY2F0aW9ucyB0aGF0IHVzZSBPX0RJUkVDVCBvbiBORlMgdG8g
Y2FsbCBmc3luYygpLCBzaW5jZSB3ZSBhbHdheXMgZW5mb3JjZSBPX0RJUkVDVHxPX1NZTkMgc2Vt
YW50aWNzLg0KDQo=

