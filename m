Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12201 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757968Ab2EVOhx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 10:37:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] NFS: put net on idr allocation failure
Date: Tue, 22 May 2012 14:37:41 +0000
Message-ID: <1337697459.4269.7.camel@lade.trondhjem.org>
References: <20120522073709.20602.33027.stgit@localhost.localdomain>
	 <20120522080307.21303.60025.stgit@localhost.localdomain>
In-Reply-To: <20120522080307.21303.60025.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTIyIGF0IDEyOjAzICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gU2lnbmVkLW9mZi1ieTogU3RhbmlzbGF2IEtpbnNidXJza3kgPHNraW5zYnVyc2t5
QHBhcmFsbGVscy5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL2NsaWVudC5jIHwgICAgNCArKystDQo+
ICAxIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkNCj4gDQo+
IGRpZmYgLS1naXQgYS9mcy9uZnMvY2xpZW50LmMgYi9mcy9uZnMvY2xpZW50LmMNCj4gaW5kZXgg
NDRjZDcwZi4uYWUyOWQ0ZiAxMDA2NDQNCj4gLS0tIGEvZnMvbmZzL2NsaWVudC5jDQo+ICsrKyBi
L2ZzL25mcy9jbGllbnQuYw0KPiBAQCAtMTc2LDggKzE3NiwxMCBAQCBzdGF0aWMgc3RydWN0IG5m
c19jbGllbnQgKm5mc19hbGxvY19jbGllbnQoY29uc3Qgc3RydWN0IG5mc19jbGllbnRfaW5pdGRh
dGEgKmNsXw0KPiAgDQo+ICAjaWZkZWYgQ09ORklHX05GU19WNA0KPiAgCWVyciA9IG5mc19nZXRf
Y2JfaWRlbnRfaWRyKGNscCwgY2xfaW5pdC0+bWlub3J2ZXJzaW9uKTsNCj4gLQlpZiAoZXJyKQ0K
PiArCWlmIChlcnIpIHsNCj4gKwkJcHV0X25ldChjbHAtPm5ldCk7DQo+ICAJCWdvdG8gZXJyb3Jf
Y2xlYW51cDsNCj4gKwl9DQo+ICANCj4gIAlzcGluX2xvY2tfaW5pdCgmY2xwLT5jbF9sb2NrKTsN
Cj4gIAlJTklUX0RFTEFZRURfV09SSygmY2xwLT5jbF9yZW5ld2QsIG5mczRfcmVuZXdfc3RhdGUp
Ow0KPiANCg0KTGV0J3MganVzdCBtb3ZlIHRoZSBhY3R1YWwgZ2V0X25ldCgpIGNhbGwgdG8gdGhl
IGVuZCBvZiB0aGUgZnVuY3Rpb24uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
