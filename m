Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:56083 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964948Ab3GRUFA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 16:05:00 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Should BIND_CONN_TO_SESSION be allowed to return NFS4ERR_WRONG_CRED
Date: Thu, 18 Jul 2013 20:04:58 +0000
Message-ID: <1374177896.3788.67.camel@leira.trondhjem.org>
References: <7EC48508-29F6-42DF-9BBA-F90A5CA1A47C@netapp.com>
	 <1374159436.3788.3.camel@leira.trondhjem.org>
	 <DFCAA8D0-B3BD-49C2-BAC4-9C26668AACB9@netapp.com>
	 <1374160910.3788.14.camel@leira.trondhjem.org>
	 <1D61D5F4-40DA-47D1-A15A-745EA05813BA@netapp.com>
	 <1374167339.3788.52.camel@leira.trondhjem.org>
	 <DD04268F-B364-48D0-ADEB-E4770D618B38@netapp.com>
	 <9AC7EBEB-E407-4CCB-A6E6-05C24CD821DA@netapp.com>
	 <1374177242.3788.59.camel@leira.trondhjem.org>
In-Reply-To: <1374177242.3788.59.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEzLTA3LTE4IGF0IDE1OjU0IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFRodSwgMjAxMy0wNy0xOCBhdCAxOTo0OSArMDAwMCwgQWRhbXNvbiwgRHJvcyB3cm90
ZToNCj4gPiBPbmx5IHN1cHBvcnRpbmcgb3BlcmF0aW9ucyB0aGF0IGhhdmUgdGhlIGVycm9yIGNv
ZGUgTkZTNEVSUl9XUk9OR19DUkVEIHNlZW1zIHRvIGJlIHdyb25nLiAgT3BlcmF0aW9ucyBsaWtl
IEJJTkRfQ09OTl9UT19TRVNTSU9OIGRvbid0IHN1cHBvcnQgZG9uJ3Qgc3VwcG9ydCB0aGlzIGVy
cm9yIGNvZGUsIGJ1dCBhcmUgZXhwbGljaXRseSBtZW50aW9uZWQgaW4gU1A0X01BQ0hfQ1JFRCBz
ZWN0aW9ucyBvZiB0aGUgc3BlYy4NCj4gDQo+IExvb2tpbmcgYXQgdGhlIGFsbG93ZWQgZXJyb3Ig
cmV0dXJuIHZhbHVlcyBmb3IgQklORF9DT05OX1RPX1NFU1NJT04sIEknbQ0KPiBhdCBhIGxvc3Mg
dG8gZmlndXJlIG91dCBleGFjdGx5IHdoYXQgaXQgc2hvdWxkIHJldHVybiBpbiB0aGlzIGNhc2Uu
IEkNCj4gc3VzcGVjdCB0aGF0IHRoZSBsYWNrIG9mIGFuIE5GUzRFUlJfV1JPTkdfQ1JFRCBpcyBh
Y3R1YWxseSBhIHByb3RvY29sDQo+IGJ1Zy4NCj4gDQo+IFRpbWUgdG8gZ28gYmFjayB0byB0aGUg
aWV0ZiBtYWlsaW5nIGxpc3QuLi4NCg0KSGkgYWxsLA0KDQpXaGVuIGF0dGVtcHRpbmcgdG8gaW1w
bGVtZW50IHRoZSBTUDRfTUFDSF9DUkVEIHN0YXRlIHByb3RlY3Rpb24sIERyb3MNCnJhbiBpbnRv
IGFuIGlzc3VlLiBJZiB0aGUgQklORF9DT05OX1RPX1NFU1NJT04gb3BlcmF0aW9uIGlzIGxpc3Rl
ZCBpbg0KdGhlICJzcG9fbXVzdF9lbmZvcmNlIiBsaXN0IG9mIG9wZXJhdGlvbnMsIHdoYXQgc2hv
dWxkIGl0IG5vdCBiZSBhbGxvd2VkDQp0byByZXR1cm4gTkZTNEVSUl9XUk9OR19DUkVEIGlmIGNh
bGxlZCB3aXRoIGEgY3JlZGVudGlhbCB0aGF0IGlzIG5vdCB0aGUNCm1hY2hpbmUgb3IgU1NWIGNy
ZWRlbnRpYWw/DQoNCkNoZWVycw0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAu
Y29tDQp3d3cubmV0YXBwLmNvbQ0K
