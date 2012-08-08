Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46023 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758563Ab2HHS5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 14:57:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH RFC 3/3] NFS41: send real read size in layoutget for DIO
Date: Wed, 8 Aug 2012 18:57:05 +0000
Message-ID: <1344452224.8925.30.camel@lade.trondhjem.org>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
	 <1344391392-1948-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344391392-1948-4-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTA4IGF0IDEwOjAzICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gRnJv
bTogUGVuZyBUYW8gPHRhby5wZW5nQGVtYy5jb20+DQo+IA0KPiBXZSBkb24ndCBoYXZlIHRoZSBy
ZWFsIElPIHNpemUgaW5mb3JtYXRpb24gaW4gYnVmZmVyIHJlYWQsIGJ1dCBmb3IgZGlyZWN0DQo+
IHJlYWQsIHdlIGNhbiBnZXQgaXQgZnJvbSBkcmVxLT5ieXRlc19sZWZ0LiBMZXQncyBtYWtlIHVz
ZSBvZiBpdC4NCg0KV2hhdCdzIHdyb25nIHdpdGggdXNpbmcgdGhlIG5mc19yZWFkcGFnZXMgYXJn
dW1lbnRzPyBUaGUgcmVhZGFoZWFkIGNvZGUNCndpbGwgdGVsbCB5b3UgZXhhY3RseSBob3cgbWFu
eSBwYWdlcyBpdCBpcyB0cnlpbmcgdG8gcmVhZC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
