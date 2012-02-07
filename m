Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756140Ab2BGOLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 09:11:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 4/4] NFS: make nfs_client_lock per net ns
Date: Tue, 7 Feb 2012 14:11:46 +0000
Message-ID: <1328623906.4124.10.camel@lade.trondhjem.org>
References: <20120123172631.29637.17188.stgit@localhost6.localdomain6>
	 <1328622659.4124.3.camel@lade.trondhjem.org>
	 <4F31308B.1090002@parallels.com>
In-Reply-To: <4F31308B.1090002@parallels.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAyLTA3IGF0IDE4OjA5ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gMDcuMDIuMjAxMiAxNzo1MSwgTXlrbGVidXN0LCBUcm9uZCDQv9C40YjQtdGCOg0K
PiA+IDg8LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KPiA+ICBGcm9tIDVhNDg5MTU2ZGE0ZmQxNWRkMTQzZjJi
MjFkZDk2NTdiOTdkY2VmODggTW9uIFNlcCAxNyAwMDowMDowMCAyMDAxDQo+ID4gRnJvbTogVHJv
bmQgTXlrbGVidXN0PFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPg0KPiA+IERhdGU6IFR1ZSwg
NyBGZWIgMjAxMiAwMDowNToxMSAtMDUwMA0KPiA+IFN1YmplY3Q6IFtQQVRDSF0gTkZTOiBJbml0
aWFsaXNlIHRoZSBuZnNfbmV0LT5uZnNfY2xpZW50X2xvY2sNCj4gPg0KPiA+IEVuc3VyZSB0aGF0
IHdlIGluaXRpYWxpc2UgdGhlIG5mc19uZXQtPm5mc19jbGllbnRfbG9jayBzcGlubG9jay4NCj4g
PiBBbHNvIGVuc3VyZSB0aGF0IG5mc19zZXJ2ZXJfcmVtb3ZlX2xpc3RzKCkgZG9lc24ndCB0cnkg
dG8NCj4gPiBkZXJlZmVyZW5jZSBzZXJ2ZXItPm5mc19jbGllbnQgYmVmb3JlIHRoYXQgaXMgaW5p
dGlhbGlzZWQuDQo+ID4NCj4gDQo+IFNvcnJ5Lg0KPiBQYXRjaCBsb29rcyBuaWNlLiBFeGNlcHQg
b25lIG5vdGljZSBiZWxvdy4NCj4gDQo+ID4gU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVidXN0
PFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPg0KPiA+IENjOiBTdGFuaXNsYXYgS2luc2J1cnNr
eTxza2luc2J1cnNreUBwYXJhbGxlbHMuY29tPg0KPiA+IC0tLQ0KPiA+ICAgZnMvbmZzL2NsaWVu
dC5jIHwgICAgNiArKysrKy0NCj4gPiAgIDEgZmlsZXMgY2hhbmdlZCwgNSBpbnNlcnRpb25zKCsp
LCAxIGRlbGV0aW9ucygtKQ0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL2ZzL25mcy9jbGllbnQuYyBi
L2ZzL25mcy9jbGllbnQuYw0KPiA+IGluZGV4IDFhNWNkNDkuLmYwZGFjYWQgMTAwNjQ0DQo+ID4g
LS0tIGEvZnMvbmZzL2NsaWVudC5jDQo+ID4gKysrIGIvZnMvbmZzL2NsaWVudC5jDQo+ID4gQEAg
LTEwNTUsOCArMTA1NSwxMSBAQCBzdGF0aWMgdm9pZCBuZnNfc2VydmVyX2luc2VydF9saXN0cyhz
dHJ1Y3QgbmZzX3NlcnZlciAqc2VydmVyKQ0KPiA+ICAgc3RhdGljIHZvaWQgbmZzX3NlcnZlcl9y
ZW1vdmVfbGlzdHMoc3RydWN0IG5mc19zZXJ2ZXIgKnNlcnZlcikNCj4gPiAgIHsNCj4gPiAgIAlz
dHJ1Y3QgbmZzX2NsaWVudCAqY2xwID0gc2VydmVyLT5uZnNfY2xpZW50Ow0KPiA+IC0Jc3RydWN0
IG5mc19uZXQgKm5uID0gbmV0X2dlbmVyaWMoY2xwLT5uZXQsIG5mc19uZXRfaWQpOw0KPiA+ICsJ
c3RydWN0IG5mc19uZXQgKm5uOw0KPiA+DQo+ID4gKwlpZiAoY2xwID09IE5VTEwpDQo+ID4gKwkJ
cmV0dXJuOw0KPiA+ICsJbm4gPSBuZXRfZ2VuZXJpYyhjbHAtPm5ldCwgbmZzX25ldF9pZCk7DQo+
ID4gICAJc3Bpbl9sb2NrKCZubi0+bmZzX2NsaWVudF9sb2NrKTsNCj4gPiAgIAlsaXN0X2RlbF9y
Y3UoJnNlcnZlci0+Y2xpZW50X2xpbmspOw0KPiA+ICAgCWlmIChjbHAmJiAgbGlzdF9lbXB0eSgm
Y2xwLT5jbF9zdXBlcmJsb2NrcykpDQo+IA0KPiBUaGlzIGNoZWNrIGZvciBjbHAgIT0gTlVMTCBj
YW4gYmUgcmVtb3ZlZC4NCj4gDQoNClllcC4uLiBJJ2xsIGFkZCB0aGF0IGluLi4uDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpU
cm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
