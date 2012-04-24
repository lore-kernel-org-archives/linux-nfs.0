Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28669 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab2DXP6m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 11:58:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jim Rees <rees@umich.edu>, Niels de Vos <ndevos@redhat.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: Only listen on requested hostnames for
 NC_TPI_COTS connections
Date: Tue, 24 Apr 2012 15:58:26 +0000
Message-ID: <1335283106.3792.39.camel@lade.trondhjem.org>
References: <1335194692-6714-1-git-send-email-ndevos@redhat.com>
	 <82D8C43F-5C40-444C-9573-B4FF95F615DA@oracle.com>
	 <4F957D30.9010102@redhat.com>
	 <7C71F75F-3F15-401B-8700-38B0EBE2B595@oracle.com>
	 <4F96C0E3.9090007@redhat.com> <20120424152950.GB13191@umich.edu>
	 <2332F6F6-A1CF-4C0A-A35C-4E4EE588EC1D@oracle.com>
In-Reply-To: <2332F6F6-A1CF-4C0A-A35C-4E4EE588EC1D@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA0LTI0IGF0IDExOjQwIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
T24gQXByIDI0LCAyMDEyLCBhdCAxMToyOSBBTSwgSmltIFJlZXMgd3JvdGU6DQo+IA0KPiA+IE5p
ZWxzIGRlIFZvcyB3cm90ZToNCj4gPiANCj4gPiAgT24gMDQvMjMvMjAxMiAwNjoyMiBQTSwgQ2h1
Y2sgTGV2ZXIgd3JvdGU6DQo+ID4+IA0KPiA+PiBTbyB5b3UgZGlkIGNoZWNrIHRoZSBtYWlsIGFy
Y2hpdmU/ICBJIHNlZW0gdG8gcmVjYWxsIG90aGVyIHBhdGNoZXMgbGlrZQ0KPiA+PiB0aGlzIGlu
IHRoZSBwYXN0LCBhbmQgdGhhdCB0aGVyZSBpcyBhIHJlYXNvbiB3aHkgcnBjYmluZCB3b3JrcyB0
aGlzIHdheS4NCj4gPj4gSSBzaW1wbHkgZG9uJ3QgcmVtZW1iZXIgdGhlIHNwZWNpZmljcyByaWdo
dCBhdCB0aGUgbW9tZW50Lg0KPiA+IA0KPiA+ICBJIGRpZCwgYnV0IG5vIG1lc3NhZ2VzIGFib3V0
IHRoaXMgc3ViamVjdCBjb21lIHVwIGZvciBtZS4uLiBNYXliZSBJJ20gbG9va2luZw0KPiA+ICBp
biB0aGUgd3JvbmcgcGxhY2VzIDotLw0KPiA+IA0KPiA+IEkgYXNrZWQgYWJvdXQgdGhpcyBsYXN0
IE5vdmVtYmVyLCBhbmQgYXQgdGhhdCB0aW1lIENodWNrIHJlZmVycmVkIG1lIHRvIHRoZQ0KPiA+
IG1haWwgYXJjaGl2ZSB0b28uICBJIGNvdWxkbid0IGZpbmQgYW55IGRpc2N1c3Npb24gZWl0aGVy
LiAgQnV0IHRoZSBiZWhhdmlvcg0KPiA+IGlzIGludGVudGlvbmFsLCBzbyBJIGRvbid0IHRoaW5r
IHlvdSdsbCBnZXQgYSBwYXRjaCBhY2NlcHRlZC4NCj4gDQo+IEdvaW5nIGJhY2sgdG8gdGhlIHJw
Y2JpbmQoOCkgbWFuIHBhZ2UsIHRoZSAiLWgiIGlzIG1lYW50IHRvIHdvcmsgYXJvdW5kIGEgYnJv
a2VubmVzcyBvZiBSUEMgb3ZlciBVRFAuICBVRFAgcmVwbGllcyBjYW4gY29tZSBmcm9tIGFueSBz
ZXJ2ZXIgYWRkcmVzcywgYXMgSSBtZW50aW9uZWQgYmVmb3JlLCBhbmQgbW9zdCBMaW51eCBjbGll
bnRzLCBhdCBsZWFzdCwgZG9uJ3QgbGlrZSBhbiBSUEMgcmVwbHkgdG8gY29tZSBmcm9tIGEgZGlm
ZmVyZW50IGFkZHJlc3MgdGhhbiB0aGUgcmVxdWVzdCB3YXMgc2VudCB0by4NCg0KU2VlIHRoZSBJ
UF9QS1RJTkZPIHNvY2tldCBjb250cm9sIG1lc3NhZ2UgZGVmaW5pdGlvbiBmb3IgdGhlIGNvcnJl
Y3Qgd2F5DQp0byBkbyB0aGlzICgnbWFuIDcgaXAnKS4gVGhhdCBpcyBob3cgdGhlIGtlcm5lbCBS
UEMgc2VydmVyIGNvZGUNCmRldGVybWluZXMgdG8gd2hpY2ggYWRkcmVzcyB0aGUgbWVzc2FnZSB3
YXMgc2VudCwgYW5kIGlzIGhvdyBpdCBzZXRzIHRoZQ0KcmVwbHkncyBzb3VyY2UgYWRkcmVzcy4u
Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoN
Ck5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
