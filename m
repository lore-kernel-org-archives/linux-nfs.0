Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:50883 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756352Ab3HGRMm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 13:12:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 2/2] NFSv4.1 Use the MDS nfs_server authflavor
 for pNFS data server connections
Date: Wed, 7 Aug 2013 17:12:40 +0000
Message-ID: <1375895560.7280.8.camel@leira.trondhjem.org>
References: <1374681590-2134-1-git-send-email-andros@netapp.com>
	 <1374681590-2134-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374681590-2134-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA3LTI0IGF0IDExOjU5IC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IHBORlMg
ZGF0YSBzZXJ2ZXJzIGFyZSBub3QgbW91bnRlZCBpbiB0aGUgbm9ybWFsIHNlbnNlIGFzIHRoZXJl
IGlzIG5vIGFzc29jaWF0ZWQNCj4gbmZzX3NlcnZlciBzdHJ1Y3R1cmUuDQo+IA0KPiBDb21taXQg
NGVkYWEzMDggIk5GUzogVXNlICJrcmI1aSIgdG8gZXN0YWJsaXNoIE5GU3Y0IHN0YXRlIHdoZW5l
dmVyIHBvc3NpYmxlIg0KPiB1c2VzIHRoZSBuZnNfY2xpZW50IGNsX3JwY2NsaWVudCBmb3IgYWxs
IHN0YXRlIG1hbmFnZW1lbnQgb3BlcmF0aW9ucywgYW5kDQo+IHdpbGwgdXNlIGtyYjVpIG9yIGF1
dGhfc3lzIHdpdGggbm8gcmVnYXJkIHRvIHRoZSBtb3VudCBjb21tYW5kIGF1dGhmbGF2b3INCj4g
Y2hvaWNlLiAgRm9yIG5vcm1hbCBtb3VudGVkIHNlcnZlcnMsIHRoZSBuZnNfc2VydmVyIGNsaWVu
dCBhdXRoZmxhdm9yIGlzIHVzZWQNCj4gZm9yIGFsbCBub24tc3RhdGUgbWFuYWdlbWVudCBvcGVy
YXRpb25zDQo+IA0KPiBEYXRhIHNlcnZlcnMgdXNlIHRoZSBzYW1lIGF1dGhmbGF2b3IgYXMgdGhl
IE1EUyBtb3VudCBmb3Igbm9uLXN0YXRlIG1hbmFnZW1lbnQNCj4gb3BlcmF0aW9ucy4gTm90ZSB0
aGF0IHRoZSBNRFMgaGFzIHBlcmZvcm1lZCBhbnkgc3ViLW1vdW50cyBhbmQgY3JlYXRlZCBhbg0K
PiBuZnNfc2VydmVyIHJwYyBjbGllbnQuIEFkZCBhbiBhcnJheSBvZiBzdHJ1Y3QgcnBjX2NsbnQg
dG8gc3RydWN0DQo+IG5mc19jbGllbnQsIG9uZSBmb3IgZWFjaCBwb3NzaWJsZSBhdXRoIGZsYXZv
ciBmb3IgZGF0YSBzZXJ2ZXIgUlBDIGNvbm5lY3Rpb25zLg0KPiANCj4gU2lnbmVkLW9mZi1ieTog
QW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCg0KUXVlc3Rpb246IGRvIHdlIGFsc28g
bmVlZCB0byBhZGQgc3VwcG9ydCBmb3IgU0VDSU5GT19OT19OQU1FPyBJSVJDLCB0aGUNCnNwZWMg
c2F5cyB0aGF0IHdlIGRvLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVu
dCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5u
ZXRhcHAuY29tDQo=
