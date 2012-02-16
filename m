Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab2BPTs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 14:48:28 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GJmSWc012134
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 11:48:28 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 16 Feb 2012 19:48:20 +0000
Message-ID: <1329421700.4279.21.camel@lade.trondhjem.org>
References: <1329171728-3980-1-git-send-email-dros@netapp.com>
In-Reply-To: <1329171728-3980-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAyLTEzIGF0IDE3OjIyIC0wNTAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL3hwcnQuYyBiL25ldC9zdW5ycGMveHBy
dC5jDQo+IGluZGV4IGVmZTU0OTUuLmFiN2EyOGYgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMv
eHBydC5jDQo+ICsrKyBiL25ldC9zdW5ycGMveHBydC5jDQo+IEBAIC0xMTMyLDcgKzExMzIsMTAg
QEAgdm9pZCB4cHJ0X3JlbGVhc2Uoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiAgCQlyZXR1cm47
DQo+ICANCj4gIAl4cHJ0ID0gcmVxLT5ycV94cHJ0Ow0KPiAtCXJwY19jb3VudF9pb3N0YXRzKHRh
c2spOw0KPiArCWlmICh0YXNrLT50a19jbGllbnQpDQo+ICsJCXJwY19jb3VudF9pb3N0YXRzKHRh
c2ssIHRhc2stPnRrX2NsaWVudC0+Y2xfbWV0cmljcyk7DQo+ICsJaWYgKHRhc2stPnRrX29wcy0+
cnBjX2NvdW50X3N0YXRzICE9IE5VTEwpDQo+ICsJCXRhc2stPnRrX29wcy0+cnBjX2NvdW50X3N0
YXRzKHRhc2ssIHRhc2stPnRrX2NhbGxkYXRhKTsNCj4gIAlzcGluX2xvY2tfYmgoJnhwcnQtPnRy
YW5zcG9ydF9sb2NrKTsNCj4gIAl4cHJ0LT5vcHMtPnJlbGVhc2VfeHBydCh4cHJ0LCB0YXNrKTsN
Cj4gIAlpZiAoeHBydC0+b3BzLT5yZWxlYXNlX3JlcXVlc3QpDQoNCjIgbml0czoNCg0KICAgICAx
LiBBcmVuJ3Qgd2UgZ3VhcmFudGVlZCB0aGF0IHRhc2stPnRrX2NsaWVudCAhPSBOVUxMIGluDQog
ICAgICAgIHhwcnRfcmVsZWFzZSgpPw0KICAgICAyLiBTaG91bGRuJ3Qgd2UgYmUgY2FsbGluZyBf
ZWl0aGVyXyBycGNfY291bnRfaW9zdGF0cygpLCBfb3JfDQogICAgICAgIHRhc2stPnRrX29wcy0+
cnBjX2NvdW50X3N0YXRzKCk/IEFzIGZhciBhcyBJIGNhbiBzZWUsIHRoZQ0KICAgICAgICBuZnNz
dGF0IG91dHB1dCB3aWxsIG5vdyBiZSBkb3VibGUtY291bnRpbmcgYW5kIHBORlMgcmVhZHMsDQog
ICAgICAgIHdyaXRlcyBhbmQgY29tbWl0cyB0aGF0IGFyZSBzZW50IHRvIHRoZSBEUy4NCg0KQ2hl
ZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFw
cC5jb20NCg0K
