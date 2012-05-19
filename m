Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65171 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756038Ab2ESVTd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 May 2012 17:19:33 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4JLJI3L027172
	for <linux-nfs@vger.kernel.org>; Sat, 19 May 2012 14:19:18 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 4 01/13] NFSv4.1 do not send LAYOUTRETURN when
 there are no layout segments
Date: Sat, 19 May 2012 21:18:33 +0000
Message-ID: <1337462356.4831.51.camel@lade.trondhjem.org>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
	 <1335563633-7191-2-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTI3IGF0IDE3OjUzIC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMv
bmZzL3BuZnMuYyB8ICAgIDIgKy0NCj4gIDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCsp
LCAxIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9wbmZzLmMgYi9mcy9u
ZnMvcG5mcy5jDQo+IGluZGV4IDVlMTE1NTcuLjQ2M2ViMmYgMTAwNjQ0DQo+IC0tLSBhL2ZzL25m
cy9wbmZzLmMNCj4gKysrIGIvZnMvbmZzL3BuZnMuYw0KPiBAQCAtNjU3LDcgKzY1Nyw3IEBAIF9w
bmZzX3JldHVybl9sYXlvdXQoc3RydWN0IGlub2RlICppbm8pDQo+ICANCj4gIAlzcGluX2xvY2so
Jmluby0+aV9sb2NrKTsNCj4gIAlsbyA9IG5mc2ktPmxheW91dDsNCj4gLQlpZiAoIWxvKSB7DQo+
ICsJaWYgKCFsbyB8fCBsaXN0X2VtcHR5KCZsby0+cGxoX3NlZ3MpKSB7DQo+ICAJCXNwaW5fdW5s
b2NrKCZpbm8tPmlfbG9jayk7DQo+ICAJCWRwcmludGsoIiVzOiBubyBsYXlvdXQgdG8gcmV0dXJu
XG4iLCBfX2Z1bmNfXyk7DQo+ICAJCXJldHVybiBzdGF0dXM7DQoNCkhtbS4uLiBBcmVuJ3Qgd2Ug
YmV0dGVyIG9mZiBkb2luZyB0aGlzIGlmIHRoZSBjYWxsIHRvDQptYXJrX21hdGNoaW5nX2xzZWdz
X2ludmFsaWQoKSByZXR1cm5zIGFuIGVtcHR5IGxpc3Q/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
