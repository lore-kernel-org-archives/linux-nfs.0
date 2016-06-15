Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:21547 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932769AbcFOPpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 11:45:44 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Wed, 15 Jun 2016 15:45:37 +0000
Message-ID: <E6003989-FB5F-4FE8-A161-C6E52E031091@primarydata.com>
References: <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
 <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
 <20160615144801.GB18524@infradead.org>
 <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
 <20160615145638.GC5297@infradead.org>
 <02DCF6B5-AFDF-4E33-A8F2-DBFE67A87E91@primarydata.com>
 <20160615151422.GA28557@infradead.org>
In-Reply-To: <20160615151422.GA28557@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTUvMTYsIDExOjE0LCAiQ2hyaXN0b3BoIEhlbGx3aWciIDxoY2hAaW5mcmFkZWFk
Lm9yZz4gd3JvdGU6DQoNCj5PbiBXZWQsIEp1biAxNSwgMjAxNiBhdCAwMzowOToyM1BNICswMDAw
LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+PiBBcyBJIHNhaWQgZWFybGllciwgdGhlIHByb2Js
ZW0gd2l0aCB0aGF0IGlzIHlvdSBlbmQgdXAgYXJ0aWZpY2lhbGx5IHNlcmlhbGlzaW5nIGJ1ZmZl
cmVkIHJlYWRzIGFuZCBidWZmZXJlZCB3cml0ZXMuDQo+DQo+SWYgeW91IGFjdHVhbGx5IHdhbnQg
dG8gYmUgUG9zaXggY29tcGlhbnQgeW91IG5lZWQgdG8gc2VyaWFsaXplIGJ1ZmZlcmVkDQo+cmVh
ZHMgYWdhaW5zdCBidWZmZXJlcmQgd3JpdGVzIC0gaXQncyBqdXN0IHRoYXQgbW9zdCBMaW51eCBm
aWxlIHN5c3RlbXMNCj5oYXBwZW4gdG8gZ2V0IHRoaXMgd3JvbmcuDQo+DQo+PiA/Pz8gVGhlIHJl
YWRzIG9ubHkgbmVlZCBhIHNoYXJlZCBsb2NrIGluIG9yZGVyIHRvIHByb3RlY3QgdGhlIEkvTyBt
b2RlIGZyb20gZmxpcHBpbmcgdG8gT19ESVJFQ1QgKGFuZCByZWx5aW5nIG9uIHBhZ2UgbG9ja3Mg
dG8gcHJvdGVjdCBhZ2FpbnN0IGJ1ZmZlcmVkIHdyaXRlcykuDQo+DQo+V2hpY2ggc3RyaWN0bHkg
c3BlYWtpbmcgaXMgbm90IGVub3VnaCwgYWx0aG91Z2ggYXMgc2FpZCBhYm92ZSBtb3N0DQo+TGlu
dXggZmlsZXN5c3RlbXMgZ2V0IHRoaXMgd3JvbmcuICBJZiB5b3UgaW5kZWVkIHdhbnQgdG8ga2Vl
cCB0aGF0DQo+KGluY29ycmVjdCkgYmVoYXZpb3IgeW91IG5lZWQgYW5vdGhlciBsb2NrLiAgSXQn
cyBkZWZpbnRpdmVseSBub3QNCj4ic2ltcGxlciIsIHRob3VnaC4NCj4NCg0KU2VyaWFsaXNhdGlv
biBpcyBub3QgbWFuZGF0b3J5IGluIFBPU0lYOg0KDQpodHRwOi8vcHVicy5vcGVuZ3JvdXAub3Jn
L29ubGluZXB1YnMvOTY5OTkxOTc5OS9mdW5jdGlvbnMvd3JpdGUuaHRtbA0KDQrigJxXcml0ZXMg
Y2FuIGJlIHNlcmlhbGl6ZWQgd2l0aCByZXNwZWN0IHRvIG90aGVyIHJlYWRzIGFuZCB3cml0ZXMu
IElmIGEgcmVhZCgpIG9mIGZpbGUgZGF0YSBjYW4gYmUgcHJvdmVuIChieSBhbnkgbWVhbnMpIHRv
IG9jY3VyIGFmdGVyIGEgd3JpdGUoKSBvZiB0aGUgZGF0YSwgaXQgbXVzdCByZWZsZWN0IHRoYXQg
d3JpdGUoKSwgZXZlbiBpZiB0aGUgY2FsbHMgYXJlIG1hZGUgYnkgZGlmZmVyZW50IHByb2Nlc3Nl
cy4gQSBzaW1pbGFyIHJlcXVpcmVtZW50IGFwcGxpZXMgdG8gbXVsdGlwbGUgd3JpdGUgb3BlcmF0
aW9ucyB0byB0aGUgc2FtZSBmaWxlIHBvc2l0aW9uLiBUaGlzIGlzIG5lZWRlZCB0byBndWFyYW50
ZWUgdGhlIHByb3BhZ2F0aW9uIG9mIGRhdGEgZnJvbSB3cml0ZSgpIGNhbGxzIHRvIHN1YnNlcXVl
bnQgcmVhZCgpIGNhbGxzLiBUaGlzIHJlcXVpcmVtZW50IGlzIHBhcnRpY3VsYXJseSBzaWduaWZp
Y2FudCBmb3IgbmV0d29ya2VkIGZpbGUgc3lzdGVtcywgd2hlcmUgc29tZSBjYWNoaW5nIHNjaGVt
ZXMgdmlvbGF0ZSB0aGVzZSBzZW1hbnRpY3Mu4oCdDQoNCg==

