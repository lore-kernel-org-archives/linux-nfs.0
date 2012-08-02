Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42035 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab2HBVdP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Aug 2012 17:33:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: wait_for_key_construction oops
Date: Thu, 2 Aug 2012 21:33:13 +0000
Message-ID: <1343943192.26497.2.camel@lade.trondhjem.org>
References: <CAJ75kXZb2_MGOrxG6JRyGEKdHm+t_yUk755DpqTvpdyVZ4TFzg@mail.gmail.com>
	 <1343687301.28035.11.camel@lade.trondhjem.org>
	 <CAJ75kXb=GpKFkOQRiMqqpoH6+wEOP4sh5spS4Y8y-k__mbE6kA@mail.gmail.com>
	 <CAJ75kXYqHpLXUqW3FkVsXu3=pybaBaTZ0AGfRG8ur8OcwGKX-w@mail.gmail.com>
In-Reply-To: <CAJ75kXYqHpLXUqW3FkVsXu3=pybaBaTZ0AGfRG8ur8OcwGKX-w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA4LTAyIGF0IDIzOjI4ICswMjAwLCBXaWxsaWFtIERhdWNoeSB3cm90ZToN
Cj4gT24gVHVlLCBKdWwgMzEsIDIwMTIgYXQgMTA6MDcgQU0sIFdpbGxpYW0gRGF1Y2h5IDx3ZGF1
Y2h5QGdtYWlsLmNvbT4gd3JvdGU6DQo+ID4gSSBndWVzcyB0aGF0IHRoZSBmaXhlcyBmcm9tIERh
dmlkIEhvd2VsbHMgKGE0MjdiOWUpIGFyZSByZWxhdGVkIHRvIG15DQo+ID4gb29wcyBJIG1lbnRp
b25lZDsgcGFydGljdWxhcmx5IHRoZSBwb2ludCA0IGluIGhpcyBjb21taXQuDQo+IA0KPiBTZWVt
cyBub3QgYmVjYXVzZSBJJ20gYWxzbyBzdGlsbCBnZXR0aW5nIHRoaXMgb29wcyBvbiB3YWl0X2Zv
cl9rZXlfY29uc3RydWN0aW9uDQoNCkhhdmUgeW91IGFwcGxpZWQgY29tbWl0IGIxMDI3NDM5ZGZm
ODQ0Njc1ZjZjMGRmOTdhMWIxZDE5MDc5MWE2OTkgKE5GUzoNCkZvcmNlIHRoZSBsZWdhY3kgaWRt
YXBwZXIgdG8gYmUgc2luZ2xlIHRocmVhZGVkKT8gVGhhdCBwYXRjaCBpcyBDYzoNCnN0YWJsZSBb
Pj0zLjRdLCBhbmQgc28gbmVlZHMgdG8gYmUgYXBwbGllZCB0byB5b3VyIGtlcm5lbC4NCg0KVGhl
cmUgaXMgYWxzbyBhIG1pbm9yIGZpeCBmcm9tIERhbiBDYXJwZW50ZXIgaW4gY29tbWl0DQo1YWJj
MDNjZDkxOTUzNWM2MWI4MTNmMjMxOWNiMzgzMjZhNDFlODEwIChORlM6IGttYWxsb2MoKSBkb2Vz
bid0IHJldHVybg0KYW4gRVJSX1BUUigpKSB0aGF0IHNob3VsZCBiZSBhcHBsaWVkLg0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0K
VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
