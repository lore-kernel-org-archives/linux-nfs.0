Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:60945 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754988Ab3HGP1d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 11:27:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Nix <nix@esperi.org.uk>
CC: Jeff Layton <jlayton@redhat.com>,
        =?utf-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic
 from 3.9.*
Date: Wed, 7 Aug 2013 15:27:31 +0000
Message-ID: <1375889252.6488.1.camel@leira.trondhjem.org>
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	 <20130805084436.69ee4415@corrin.poochiereds.net>
	 <87siyotcri.fsf@spindle.srvr.nix>
	 <20130805110427.509db424@tlielax.poochiereds.net>
	 <20130805111106.73d6ab90@tlielax.poochiereds.net>
	 <87zjswrvaq.fsf@spindle.srvr.nix>
	 <1375719301.7337.14.camel@leira.trondhjem.org>
	 <20130805133739.21654ecb@tlielax.poochiereds.net>
	 <1375726682.7337.29.camel@leira.trondhjem.org>
	 <20130805143311.4ae59067@tlielax.poochiereds.net>
	 <1375755693.7337.42.camel@leira.trondhjem.org>
	 <87iozhst0s.fsf@spindle.srvr.nix>
In-Reply-To: <87iozhst0s.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTA3IGF0IDExOjE4ICswMTAwLCBOaXggd3JvdGU6DQo+IE9uIDYgQXVn
IDIwMTMsIFRyb25kIE15a2xlYnVzdCB2ZXJiYWxpc2VkOg0KPiA+IFRydWUuIEhvdyBhYm91dCBz
b21ldGhpbmcgbGlrZSB0aGUgZm9sbG93aW5nIGluc3RlYWQuIE5vdGUgdGhlIGNoYW5nZSB0bw0K
PiA+IHRoZSBvcmlnaW5hbCBwYXRjaC4uLg0KPiANCj4gV2VsbCwgd2l0aCB0aG9zZSBhcHBsaWVk
IEkgY291bGQgcmVib290IHdpdGhvdXQgYSBwYW5pYyBmb3IgdGhlIGZpcnN0DQo+IHRpbWUgc2lu
Y2UgMy44Lng6IGxvb2tpbmcgZ29vZC4gSSdsbCBnaXZlIGl0IGEgcmVib290IG9yIHR3byB3aXRo
IGENCj4gc3lzdGVtIHRoYXQncyBub3QgaG90IGZyb20gYm9vdGluZyB0aG91Z2guDQo+IA0KDQpD
b3VsZCB5b3UgcGxlYXNlIGFsc28gdHJ5IGFwcGx5aW5nIG9ubHkgdGhlIDEvMiBwYXRjaCwgdG8g
c2VlIGlmIHRoYXQNCnN1ZmZpY2VzIHRvIHF1ZWxsIHRoZSBzaHV0ZG93biBwYW5pYz8NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHAN
ClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
