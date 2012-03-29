Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932609Ab2C2ALj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 20:11:39 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Namjae Jeon <linkinjeon@gmail.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
Date: Thu, 29 Mar 2012 00:11:16 +0000
Message-ID: <1332979882.19172.38.camel@lade.trondhjem.org>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
	 <38AF6CFC-8017-4D08-8DB0-A80BA724E54A@netapp.com>
	 <1332947296.11400.7.camel@lade.trondhjem.org>
	 <74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
	 <CAKYAXd-eWRrja8bGqS7tTWehPNgAM4gtPALfAexRvTwkbbBOGw@mail.gmail.com>
In-Reply-To: <CAKYAXd-eWRrja8bGqS7tTWehPNgAM4gtPALfAexRvTwkbbBOGw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTI5IGF0IDA4OjU1ICswOTAwLCBOYW1qYWUgSmVvbiB3cm90ZToNCj4g
SGkuIFRyb25kLg0KPiANCj4gTm9ybWFsbHkgZ290byBzdGF0ZW1lbnQgaXMgbm90IHJlY29tbWVu
ZGVkKHBpcGVsaW5lIGFuZCBicmFuY2gNCj4gcHJlZGljdGlvbikgaXQgaXMgb25seSByZWNvbW1l
bmRlZCBhcyBhIGxhc3QgcmVzb3J0IGlmIHRoZXJlIGlzIG5vDQo+IG1ldGhvZCB0byBlc2NhcGUg
dGhpcyBsb29wLg0KDQo/Pz8/Pz8/Pz8/Pz8/IEEgZ290byBpcyBhbiB1bmNvbmRpdGlvbmFsIGJy
YW5jaDsgdGhlcmUgaXMgbm8gZnVydGhlcg0KYnJhbmNoIHByZWRpY3Rpb24gaW52b2x2ZWQgb25j
ZSBvbmNlIHRoZSBwcm9jZXNzb3IgZ2V0cyB0aGUgdmFsdWUgb2YNCidlcnInIGluIHRoYXQgc3dp
dGNoIHN0YXRlbWVudCBjb3JyZWN0LiBFeGFjdGx5IGhvdyB3b3VsZCBhZGRpbmcgYW4NCmV4dHJh
IHNldCt0ZXN0IG9mIGV4Y2VwdGlvbi5yZXRyeSBhZnRlciB0aGUgc3dpdGNoKCkgaGVscCB0aGUg
YnJhbmNoDQpwcmVkaWN0b3IgaW4gdGhpcyBzaXR1YXRpb24/DQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1
c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
