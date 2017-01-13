Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:21608 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751116AbdAMTUd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 14:20:33 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] NFS: Detect unreachable NFS/RDMA servers more reliably
Date: Fri, 13 Jan 2017 19:20:22 +0000
Message-ID: <1484335221.9950.1.camel@primarydata.com>
References: <20161216164108.7060.93683.stgit@manet.1015granger.net>
         <1484242710.4686.1.camel@primarydata.com>
         <A08E9DCC-B3A3-4ABF-9704-167AB18081DE@oracle.com>
         <62E20A87-D0C8-4AEA-89B1-902B48E9EE02@primarydata.com>
         <83F23535-5ACD-41DA-B8D0-05A34AB4821F@oracle.com>
         <1484328444.5628.1.camel@primarydata.com>
         <B88C991D-855B-4F08-B0B9-D63DF8168DA1@oracle.com>
In-Reply-To: <B88C991D-855B-4F08-B0B9-D63DF8168DA1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTAxLTEzIGF0IDE0OjA4IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCg0K
PiBJIHdhcyB0aGlua2luZyBvZiB3aXJpbmcgc29tZXRoaW5nIGludG8gY2FsbF90aW1lb3V0LCBi
dXQgeHBydF90aW1lcg0KPiBsb29rcyBsaWtlIGl0IHdvdWxkIHBlcmZvcm0gdGhlIHNhbWUgam9i
LCBhbmQgdGhlcmUgaXMgYWxyZWFkeSBhDQo+IHBlci14cHJ0IGhvb2suIEknbGwgaGF2ZSBhIGxv
b2suDQo+IA0KPiBJcyBpdCBzYWZlIHRvIGNhbGwgcnBjX3J1bl90YXNrIHdoaWxlIHRyYW5zcG9y
dF9sb2NrIGlzIGhlbGQ/IElmIG5vdA0KPiBJIGNhbiBzaW1wbHkgc2NoZWR1bGUgYSBnZW5lcmlj
IHdvcmtlciB0aHJlYWQgdG8gY29uc3RydWN0IGFuZCBzZW5kDQo+IHRoZSBOVUxMLg0KDQpZb3Ug
c2hvdWxkbid0IGNhbGwgcnBjX3J1bl90YXNrKCkgZnJvbSBhIHNwaW5sb2NrIGNvbnRleHQsIGJ1
dCBsZXQncw0KY29uc2lkZXIgbW92aW5nIHRoYXQgc3BpbmxvY2sgaW50byB0aGUgeHBydC0+b3Bz
LT50aW1lcigpIGNhbGxiYWNrLiBJDQpkb24ndCByZWFsbHkgc2VlIGhvdyBpdCBpcyAgbmVlZGVk
IGZvciB0aGUgY2FzZXMgd2hlcmUgeW91IGRvbid0IGhhdmUgYQ0KY2FsbGJhY2suDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRh
DQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

