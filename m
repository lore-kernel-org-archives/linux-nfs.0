Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49298 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932449AbdJaXYi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 19:24:38 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "aweits@rit.edu" <aweits@rit.edu>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] nfsd: Fix stateid races between OPEN and CLOSE
Date: Tue, 31 Oct 2017 23:24:33 +0000
Message-ID: <1509492271.3397.8.camel@primarydata.com>
References: <20171031000951.18294-1-trond.myklebust@primarydata.com>
         <20171031000951.18294-2-trond.myklebust@primarydata.com>
         <m2vaivrlq2.fsf@discipline.rit.edu>
In-Reply-To: <m2vaivrlq2.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTEwLTMxIGF0IDE4OjMzIC0wNDAwLCBBbmRyZXcgVyBFbGJsZSB3cm90ZToN
Cj4gTm90IGRpcmVjdGx5IHJlbGF0ZWQgdG8gdGhpcyBwYXRjaCBzZXJpZXMsIGJ1dDoNCj4gDQo+
IEkga2VlcCBzdGFyaW5nIGF0IHRoZSBmYWlsdXJlIHBhdGggaW4gbmZzZDRfcHJvY2Vzc19vcGVu
MigpIGZyb20gdGhlDQo+IGNhbGwgdG8gbmZzNF9nZXRfdmZzX2ZpbGUoKSBhbmQgdGhpbmtpbmcg
dGhhdCB0aGVyZSdzIGEgbWlzc2luZyBzdGF0ZQ0KPiBjaGFuZ2UgdG8gdGhlIHN0YXRlaWQgdGhh
dCdzIHN0aWxsIGhhc2hlZCBiZWZvcmUgdGhlIG11dGV4IGlzIGRyb3BwZWQNCj4gYW5kIHRoZSBj
YWxsIHRvIHJlbGVhc2Vfb3Blbl9zdGF0ZWlkKCk/DQo+IA0KDQpJZiB0aGUgc2VxaWQ9PTEsIHNv
IHRoYXQgd2Uga25vdyB0aGlzIE9QRU4gb3AgY3JlYXRlZCB0aGF0IHN0YXRlaWQsDQp0aGVuIGl0
IHByb2JhYmx5IHNob3VsZCBiZSB1bmhhc2hlZCBhbmQgbWFya2VkIGFzIGNsb3NlZCwgc2luY2Ug
dGhlbiB3ZQ0Ka25vdyBpdCByZXByZXNlbnRzIG5vIHN0YXRlLiBPdGhlcndpc2UsIEFGQUlDUyBp
dCBzaG91bGQga2VlcCBpdHMNCmN1cnJlbnQgc3RhdGUgKyBzZXFpZC4NCg0KRG8geW91IHdhbnQg
dG8gc2VuZCBhIHBhdGNoLCBvciBzaG91bGQgSSB1cGRhdGUgdGhpcyBwYXRjaCBzZXJpZXM/IFN1
Y2gNCmEgZml4IHByb2JhYmx5IGRvZXMgd2FudCB0byBiZSBhIHN0YWJsZSBwYXRjaCwgc2luY2Ug
aXQgd2lsbCBhZmZlY3QNCmNsaWVudHMgdGhhdCBleHBlY3QgY29tcGxpYW5jZSB3aXRoIFJGQzU2
NjEvUkZDNzUzMC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFp
bnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

