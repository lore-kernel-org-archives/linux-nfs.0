Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63268 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab2IJPl7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 11:41:59 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2] SUNRPC: check current nsproxy before set of node
 name on client creation
Date: Mon, 10 Sep 2012 15:41:57 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908F96556@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120813113731.9629.31906.stgit@localhost.localdomain>
	    <20120813081054.0ee39037@corrin.poochiereds.net>
	   <4FA345DA4F4AE44899BD2B03EEEC2FA908F90888@SACEXCMBX04-PRD.hq.netapp.com>
	   <504ADED9.2020607@parallels.com>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA908F914D4@SACEXCMBX04-PRD.hq.netapp.com>
	  <504DA833.60301@parallels.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9547B@SACEXCMBX04-PRD.hq.netapp.com>
	 <504E0930.5050408@parallels.com>
In-Reply-To: <504E0930.5050408@parallels.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA5LTEwIGF0IDE5OjM3ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gSGksIFRyb25kLg0KPiBTbywgaWYgSSB1bmRlcnN0YW5kIHlvdSByaWdodCwgd2Ug
Y2FuIGNyZWF0ZSBycGMgY2xpZW50IChvciBpbmNyZWFzZSB1c2FnZSANCj4gY291bnRlcikgb24g
TlNNUFJPQ19NT04gY2FsbCBhbmQgZGVzdHJveSAob3IgZGVjcmVhc2UgdXNhZ2UgY291bnRlcikg
b24gDQo+IE5TTVBST0NfVU5NT04gY2FsbC4NCj4gV2lsbCB0aGlzIHNvbHV0aW9uIHdvcmtzPw0K
DQpUaGUgcnBjIGNsaWVudChzKSB3aWxsIG5lZWQgdG8gYmUgcGVyLW5ldC1uYW1lc3BhY2UsIHdo
aWNoIGNvbXBsaWNhdGVzDQptYXR0ZXJzIGEgbGl0dGxlIGJpdCwgYnV0IHllcywgY3JlYXRpb24g
YXQgTlNNUFJPQ19NT04sIGFuZCBkZXN0cnVjdGlvbg0KYXQgTlNNUFJPQ19VTk1PTiBzaG91bGQg
d29yay4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5l
cg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
DQo=
