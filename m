Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:43295 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755986Ab3ICUrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 16:47:37 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <william@gandi.net>
CC: William Dauchy <wdauchy@gmail.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: Re: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to
 complete
Date: Tue, 3 Sep 2013 20:47:35 +0000
Message-ID: <1378241254.6410.52.camel@leira.trondhjem.org>
References: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
	 <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
	 <1378234234.6410.36.camel@leira.trondhjem.org>
	 <20130903204431.GF22430@gandi.net>
In-Reply-To: <20130903204431.GF22430@gandi.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEzLTA5LTAzIGF0IDIyOjQ0ICswMjAwLCBXaWxsaWFtIERhdWNoeSB3cm90ZToN
Cj4gT24gU2VwMDMgMTg6NTAsIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+ID4gVGhhbmtzIGFn
YWluIGZvciB0ZXN0aW5nISBEb2VzIHRoZSBmb2xsb3dpbmcgZml4dXAgb24gdG9wIG9mIHRoZSAn
djInDQo+ID4gcGF0Y2ggYWxzbyBoZWxwPw0KPiA+IC0tLSBhL2ZzL25mcy91bmxpbmsuYw0KPiA+
ICsrKyBiL2ZzL25mcy91bmxpbmsuYw0KPiA+IEBAIC0yMTEsNyArMjExLDcgQEAgdm9pZCBuZnNf
d2FpdF9vbl9zaWxseXJlbmFtZShzdHJ1Y3QgZGVudHJ5ICpkZW50cnkpDQo+ID4gIHsNCj4gPiAg
CXN0cnVjdCBuZnNfaW5vZGUgKm5mc2kgPSBORlNfSShkZW50cnktPmRfaW5vZGUpOw0KPiA+ICAN
Cj4gPiAtCXdhaXRfZXZlbnQobmZzaS0+d2FpdHF1ZXVlLCBhdG9taWNfcmVhZCgmbmZzaS0+c2ls
bHlfY291bnQpID09IDEpOw0KPiA+ICsJd2FpdF9ldmVudChuZnNpLT53YWl0cXVldWUsIGF0b21p
Y19yZWFkKCZuZnNpLT5zaWxseV9jb3VudCkgPD0gMSk7DQo+ID4gIH0NCj4gPiAgDQo+ID4gIHZv
aWQgbmZzX2Jsb2NrX3NpbGx5cmVuYW1lKHN0cnVjdCBkZW50cnkgKmRlbnRyeSkNCj4gDQo+IGht
bW0gSSBqdXN0IHJlYWxpemVkIHlvdXIgdjIgdmVyc2lvbiBoYWQgYD09IDFgOyBpbiBmYWN0IEkg
dGVzdGVkIHlvdXIgdjENCj4gd2l0aCBgPT0gMGAuIExldCBtZSBzb21lIHRpbWUgdG8gcmV0ZXN0
IHRoZSB2Mi4NCg0KT0suIFRoYW5rcyBhZ2FpbiENCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
