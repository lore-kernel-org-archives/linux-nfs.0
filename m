Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab2BPPOB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 10:14:01 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xemul@parallels.com" <xemul@parallels.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jbottomley@parallels.com" <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [RFC PATCH] SUNRPC: connect local transports synchronously
Date: Thu, 16 Feb 2012 15:13:53 +0000
Message-ID: <1329405232.4279.4.camel@lade.trondhjem.org>
References: <20120216150507.19081.28659.stgit@localhost6.localdomain6>
In-Reply-To: <20120216150507.19081.28659.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAyLTE2IGF0IDE5OjA2ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gTG9jYWwgdHJhbnBvcnRzIHVzZXMgVU5JWCBzb2NrZXRzIGFuZCBjb25uZWN0aW5n
IG9mIHRoZXNlIHNvY2tldHMgaXMgZG9uZSBpbg0KPiBjb250ZXh0IG9mIGZpbGUgc3lzdGVtIG5h
bWVzcGFjZSAoaS5lLiB0YXNrIGZpbGUgc3lzdGVtIHJvb3QpLg0KPiBDdXJyZW5seSwgYWxsIHNv
Y2tldHMgY29ubmVjdCBvcGVyYXRpb25zIGFyZSBwZXJmb3JtZWQgYnkgcnBjaW9kIHdvcmsgcXVl
dWUsDQo+IHdoaWNoIGFjdHVhbGx5IG1lYW5zLCB0aGF0IGFueSBzZXJ2aWNlIHdpbGwgYmUgcmVn
aXN0ZXJlZCBpbiB0aGUgc2FtZSBycGNiaW5kDQo+IGluc3RhbmNlIHJlZ2FyZGxlc3MgdG8gcHJv
Y2VzcyBmaWxlIHN5c3RlbSByb290Lg0KPiBUaGlzIGlzIG5vdCBjb250YWluZXJzLCB3aGljaCB1
c3VhbGx5IGhhdmUgaXQncyBvd24gbmVzdGVkIHJvb3QuIFRoZXJlIGFyZSAyDQo+IGFwcHJvYWNo
ZXMsIGhvdyB0byBzb2x2ZSB0aGUgcHJvYmxlbS4gRmlyc3Qgb25lIGlzIHRvIHN0b3JlIHByb3Bl
ciByb290IGluDQo+IHRyYW5wb3J0IGFuZCBzd2l0Y2ggdG8gaXQgaW4gcnBjaW9kIHdvcmtxdWV1
ZSBmdW5jdGlvbiBmb3IgY29ubmVjdCBvcGVyYXRpb25zLg0KPiBCdXQgdGhpcyBsb29rcyB1Z2x5
LiBUaGUgc2Vjb25kIG9uZSBpcyB0byBjb25uZWN0IHRvIHVuaXggc29ja2V0cw0KPiBzeW5jaHJv
bm91c2x5LiBUaGlzIGFwdGNoIGltcGxlbWVudHMgdGhlIGxhc3Qgb25lLg0KDQpUaGF0IGFwcHJv
YWNoIGNhbiBmYWxsIGFmb3VsIG9mIHRoZSBzZWxpbnV4IHJlc3RyaWN0aW9ucyBvbiB0aGUgcHJv
Y2Vzcw0KY29udGV4dC4gUHJvY2Vzc2VzIHRoYXQgYXJlIGFsbG93ZWQgdG8gd3JpdGUgZGF0YSwg
bWF5IG5vdCBiZSBhbGxvd2VkIHRvDQpjcmVhdGUgc29ja2V0cyBvciBjYWxsIGNvbm5lY3QoKS4g
VGhhdCBpcyB0aGUgbWFpbiByZWFzb24gZm9yIGRvaW5nIGl0DQppbiB0aGUgcnBjaW9kIGNvbnRl
eHQsIHdoaWNoIGlzIGEgY2xlYW4ga2VybmVsIHByb2Nlc3MgY29udGV4dC4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25k
Lk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
