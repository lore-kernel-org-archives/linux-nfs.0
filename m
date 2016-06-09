Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:44118 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbcFITXz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 15:23:55 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Deepa Dinamani <deepa.kernel@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        "Al Viro" <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 18/21] fs: nfs: Make nfs boot time y2038 safe
Date: Thu, 9 Jun 2016 19:23:49 +0000
Message-ID: <89EF59F9-52D2-4F37-A7A8-52BD0FF7E98E@primarydata.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-19-git-send-email-deepa.kernel@gmail.com>
In-Reply-To: <1465448705-25055-19-git-send-email-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvOS8xNiwgMDE6MDUsICJEZWVwYSBEaW5hbWFuaSIgPGRlZXBhLmtlcm5lbEBnbWFp
bC5jb20+IHdyb3RlOg0KDQo+Ym9vdF90aW1lIGlzIHJlcHJlc2VudGVkIGFzIGEgc3RydWN0IHRp
bWVzcGVjLg0KPnN0cnVjdCB0aW1lc3BlYyBhbmQgQ1VSUkVOVF9USU1FIGFyZSBub3QgeTIwMzgg
c2FmZS4NCj5PdmVyYWxsLCB0aGUgcGxhbiBpcyB0byB1c2UgdGltZXNwZWM2NCBmb3IgYWxsIGlu
dGVybmFsDQo+a2VybmVsIHJlcHJlc2VudGF0aW9uIG9mIHRpbWVzdGFtcHMuDQo+Q1VSUkVOVF9U
SU1FIHdpbGwgYWxzbyBiZSByZW1vdmVkLg0KPlVzZSBzdHJ1Y3QgdGltZXNwZWM2NCB0byByZXBy
ZXNlbnQgYm9vdF90aW1lLg0KPkFuZCwga3RpbWVfZ2V0X3JlYWxfdHM2NCgpIGZvciB0aGUgYm9v
dF90aW1lIHZhbHVlLg0KPg0KPmJvb3RfdGltZSBpcyB1c2VkIHRvIGNvbnN0cnVjdCB0aGUgbmZz
IGNsaWVudCBib290IHZlcmlmaWVyLg0KPlRoaXMgd2lsbCBub3cgd3JhcCBpbiAyMTA2IGluc3Rl
YWQgb2YgMjAzOCBvbiAzMi1iaXQgc3lzdGVtcy4NCj5UaGUgc2VydmVyIG9ubHkgcmVsaWVzIG9u
IHRoZSB2YWx1ZSBiZWluZyBwZXJzaXN0ZW50IHVudGlsDQo+cmVib290IHNvIHRoZSB3cmFwcGlu
ZyBzaG91bGQgYmUgZmluZS4NCg0KV2UgcmVhbGx5IGRvIG5vdCBnaXZlIGEgZGFtbiBhYm91dCB3
cmFwYXJvdW5kIGhlcmUsIHNpbmNlIHRoZSBib290IHRpbWUgaXMgb25seSBldmVyIGNvbXBhcmVk
IGZvciBhbiBleGFjdCBtYXRjaCwgYW5kIHRoZSBvZGRzIG9mIHR3byByZWJvb3RzIG9jY3Vycmlu
ZyBleGFjdGx5IDJeMzIgKiAxMF45IG5hbm9zZWNvbmRzIGFwYXJ0IGFyZSBjb3NtaWNhbGx5IHNt
YWxsLi4uDQoNCklmIHN0cnVjdCB0aW1lc3BlYyBpcyBnb2luZyBhd2F5LCBjYW4gd2UganVzdCBj
b252ZXJ0IHRoaXMgaW50byBhIGt0aW1lX3Q/DQoNClRyb25kDQoNCg==

