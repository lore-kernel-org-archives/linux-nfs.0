Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21953 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab2CaVZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Mar 2012 17:25:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Sasha Levin <levinsasha928@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        "Lukas Razik" <linux@razik.name>, Pekka Enberg <penberg@kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] nfs: Don't try mounting device as nfs root unless type
 fully matches
Date: Sat, 31 Mar 2012 21:24:53 +0000
Message-ID: <1333229105.2719.17.camel@lade.trondhjem.org>
References: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com>
	 <5FF522E0-132E-4A6A-A40F-5CCD08AF800A@oracle.com>
	 <20120107181221.GA3777@umich.edu> <1326111265.30169.5.camel@lappy>
	 <CA+1xoqdQPi53GYr_Q6RtECJJcrz0TVVp4uNQX6jkfbQWQSNF7g@mail.gmail.com>
	 <D3642511-B29B-4CA7-A133-C99B711954C1@oracle.com>
	 <1333228179.2719.14.camel@lade.trondhjem.org>
	 <CA+1xoqfv82ngQ4oc5uozZQjN7PipWVjVu670-uUGC5o_3Nec9A@mail.gmail.com>
In-Reply-To: <CA+1xoqfv82ngQ4oc5uozZQjN7PipWVjVu670-uUGC5o_3Nec9A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDEyLTAzLTMxIGF0IDIzOjIxICswMjAwLCBTYXNoYSBMZXZpbiB3cm90ZToNCj4g
T24gU2F0LCBNYXIgMzEsIDIwMTIgYXQgMTE6MDkgUE0sIE15a2xlYnVzdCwgVHJvbmQNCj4gPFRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90ZToNCj4gPiBPbiBTYXQsIDIwMTItMDMtMzEg
YXQgMTE6MjcgLTA0MDAsIENodWNrIExldmVyIHdyb3RlOg0KPiA+PiBPb3BzLiAgVHJvbmQ/ICBU
aGlzIGdvdCBkcm9wcGVkIHNvbWV3aGVyZS4NCj4gPg0KPiA+IEkgZG9uJ3Qgb3duIHRoZSAnaW5p
dCcgZGlyZWN0b3J5LCBhbmQgc2luY2UgcXVpdGUgZnJhbmtseSB0aGlzIGlzbid0DQo+ID4gcmVs
YXRlZCB0byBORlMgYXQgYWxsLCBpdCBzaG91bGQgYmUgc2VudCB0byBMaW51cyBkaXJlY3RseS4N
Cj4gPg0KPiA+IEknbSBxdWl0ZSBoYXBweSB0byBhY2sgdGhlIHBhdGNoIGlmIHRoYXQgd291bGQg
aGVscC4NCj4gDQo+IFRoZSBwYXRjaCB3aGljaCBoYXMgdHJpZ2dlcmVkIHRoaXMgd2hvbGUgc3Rv
cnkgKDY4MjlhMDQ4ICgiTkZTOiBSZXRyeQ0KPiBtb3VudGluZyBORlNST09UIikpIG1vZGlmaWVk
IGluaXQvIGFzIHdlbGwsIGFuZCB3ZW50IGluIHRocm91Z2ggdGhlDQo+IE5GUyB0cmVlLiBDYW4n
dCB0aGlzIHBhdGNoIGZvbGxvdyB0aGUgc2FtZSBwYXRoPw0KDQpOby4gSXQgdG91Y2hlcyBnZW5l
cmljIGNvZGUgdW5saWtlIHRoZSBhYm92ZSBwYXRjaCwgd2hpY2ggX29ubHlfIHRvdWNoZXMNCk5G
Uy1yZWxhdGVkIGNvZGUuDQoNCj4gQW55aG93LCBJJ3ZlIENjJ2VkIExpbnVzIGluIGhvcGVzIHRo
YXQgdGhpcyBwYXRjaCBjYW4gc29tZWhvdyBmaW5kDQo+IGl0J3Mgd2F5IGludG8gMy40Lg0KDQpE
b24ndCBqdXN0IENjOiBMaW51cyBvbiB0aGlzIHRocmVhZDogc2VuZCB0aGUgcGF0Y2ggdG8gaGlt
IGRpcmVjdGx5IChhbmQNCkNjOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnKS4NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHAN
ClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
