Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db3on0080.outbound.protection.outlook.com ([157.55.234.80]:27968
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752198AbbIPHZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 03:25:29 -0400
From: =?utf-8?B?RGFtaWVuIFRow6liYXVsdA==?= <damien.thebault@vitec.com>
To: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
CC: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Wed, 16 Sep 2015 06:53:57 +0000
Message-ID: <1442386435.3756.282.camel@vitec.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
In-Reply-To: <20150911113839.GO21084@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE1LTA5LTExIGF0IDEyOjM4ICswMTAwLCBSdXNzZWxsIEtpbmcgLSBBUk0gTGlu
dXggd3JvdGU6DQo+IEkgaGF2ZSBhIHJlY2VudCBNYXJ2ZWxsIEFybWFkYSAzODggYm9hcmQgaGVy
ZSB3aGljaCB1c2VzIHRoZSBtdm5ldGENCj4gZHJpdmVyLiAgSSdtIHNlZWluZyBzb21lIHdlaXJk
IGVmZmVjdHMgd2l0aCBORlMgd2l0aCBpdCBhY3RpbmcgYXMgYQ0KPiBjbGllbnQuDQoNCkhlbGxv
LA0KDQpJJ20gdXBncmFkaW5nIGEgTWFydmVsbGUgQXJtYWRhIDM3MCBib2FyZCB1c2luZyB0aGUg
bXZuZXRhIGRyaXZlciBmcm9tDQo0LjAgdG8gNC4yIGFuZCBub3RpY2VkIGlzc3VlcyB3aXRoIE5G
UyBib290aW5nLg0KQmFzaWNhbGx5LCBtb3N0IG9mIHRoZSB0aW1lIGluaXQgcmV0dXJucyB3aXRo
IGFuIGVycm9yIGNvZGUsIG9yDQpwcm9ncmFtcyBzZWdmYXVsdCBvciB0aHJvdyBpbGxlZ2FsIGlu
c3RydWN0aW9ucy4NCg0KU2luY2UgaXQgd29ya2VkIGZpbmUgb24gNC4wIEkgYmlzZWN0ZWQgdW50
aWwgSSBmb3VuZCBjb21taXQNCmE4NGUzMjg5NDE5MWNmY2JmZmE1NDE4MGQ3OGQ3ZDQ2NTRkNTZj
MjAgIm5ldDogbXZuZXRhOiBmaXggcmVmaWxsaW5nDQpmb3IgUnggRE1BIGJ1ZmZlcnMiLg0KDQpJ
ZiBJIHJldmVydCB0aGlzIGNvbW1pdCwgZXZlcnl0aGluZyBzZWVtcyB0byBnZXQgYmFjayB0byBu
b3JtYWwuDQpDb3VsZCB5b3UgdHJ5IGl0ID8gVGhlIHR3byBpc3N1ZXMgbG9vayB2ZXJ5IHNpbWls
YXIuDQoNClJlZ2FyZHMNCi0tIA0KRGFtaWVuIFRow6liYXVsdA0KDQo=
