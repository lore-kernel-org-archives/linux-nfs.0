Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14617 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab3BQUcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2013 15:32:33 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: silence build warning in gss_fill_context
Date: Sun, 17 Feb 2013 20:32:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3EA286@sacexcmbx05-prd.hq.netapp.com>
References: <1360250946-26745-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1360250946-26745-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEzLTAyLTA3IGF0IDEwOjI5IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
U2luY2UgY29tbWl0IDYyMDAzOGY2ZDIzLCBnY2MgaXMgdGhyb3dpbmcgdGhlIGZvbGxvd2luZyB3
YXJuaW5nOg0KPiANCj4gICBDQyBbTV0gIG5ldC9zdW5ycGMvYXV0aF9nc3MvYXV0aF9nc3Mubw0K
PiBJbiBmaWxlIGluY2x1ZGVkIGZyb20gaW5jbHVkZS9saW51eC9zdW5ycGMvdHlwZXMuaDoxNDow
LA0KPiAgICAgICAgICAgICAgICAgIGZyb20gaW5jbHVkZS9saW51eC9zdW5ycGMvc2NoZWQuaDox
NCwNCj4gICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbGludXgvc3VucnBjL2NsbnQuaDox
OCwNCj4gICAgICAgICAgICAgICAgICBmcm9tIG5ldC9zdW5ycGMvYXV0aF9nc3MvYXV0aF9nc3Mu
Yzo0NToNCj4gbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRoX2dzcy5jOiBJbiBmdW5jdGlvbiDigJhn
c3NfcGlwZV9kb3duY2FsbOKAmToNCj4gaW5jbHVkZS9saW51eC9zdW5ycGMvZGVidWcuaDo0NTox
MDogd2FybmluZzog4oCYdGltZW91dOKAmSBtYXkgYmUgdXNlZA0KPiB1bmluaXRpYWxpemVkIGlu
IHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUtdW5pbml0aWFsaXplZF0NCj4gICAgIHByaW50ayhLRVJO
X0RFRkFVTFQgYXJncyk7IFwNCj4gICAgICAgICAgIF4NCj4gbmV0L3N1bnJwYy9hdXRoX2dzcy9h
dXRoX2dzcy5jOjE5NDoxNTogbm90ZTog4oCYdGltZW91dOKAmSB3YXMgZGVjbGFyZWQgaGVyZQ0K
PiAgIHVuc2lnbmVkIGludCB0aW1lb3V0Ow0KPiAgICAgICAgICAgICAgICBeDQo+IElmIHNpbXBs
ZV9nZXRfYnl0ZXMgcmV0dXJucyBhbiBlcnJvciwgdGhlbiB3ZSdsbCBlbmQgdXAgY2FsbGluZyBw
cmludGsNCj4gd2l0aCBhbiB1bmluaXRpYWxpemVkIHRpbWVvdXQgdmFsdWUuIFJlYXNvbmFibHkg
aGFybWxlc3MsIGJ1dCBmYWlybHkNCj4gc2ltcGxlIHRvIGZpeCBieSBzZXR0aW5nIHRoZSB0aW1l
b3V0IHRvIDAgaWYgaXQgZG9lcy4NCg0KIEknZCBwcmVmZXIganVzdCBkb2luZyBhIHBhcmFtZXRl
cmVjdG9teSBvbiB0aGUgZHByaW50aygpLi4uIERvIHdlDQpyZWFsbHkgbmVlZCBpdCB0byByZXBv
cnQgYW55dGhpbmcgb3RoZXIgdGhhbiBqdXN0IHRoZSBlcnJvcj8NCg0KQ2hlZXJzDQogIFRyb25k
DQo=
