Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:52158 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752047AbcKBRhn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2016 13:37:43 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Subject: Re: [PATCH v3] NFSv4: replace seqcount_t with a rw_semaphore
Date: Wed, 2 Nov 2016 17:37:37 +0000
Message-ID: <E4829318-7CA3-4516-A3D6-073E68D7A86C@primarydata.com>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161028210511.k7hrsfxovti7gqtu@linutronix.de>
 <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
 <20161031131958.mrrez5t7sow75p6v@linutronix.de>
 <51E3F753-2D1F-4370-BFEB-BD8356D622A1@primarydata.com>
 <20161031155616.fqbqy53bwpanufhn@linutronix.de>
 <40147FA4-9FD8-4349-B309-751DFCE875A2@primarydata.com>
 <20161102171149.kl66dlmlrc44zock@linutronix.de>
In-Reply-To: <20161102171149.kl66dlmlrc44zock@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE5vdiAyLCAyMDE2LCBhdCAxMzoxMSwgU2ViYXN0aWFuIEFuZHJ6ZWogU2lld2lvciA8
YmlnZWFzeUBsaW51dHJvbml4LmRlPiB3cm90ZToNCj4gDQo+IE9uIDIwMTYtMTAtMzEgMTY6MTE6
MDIgWyswMDAwXSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPj4gDQo+PiBZZXMsIGFuZCB5ZXMu
IFdlIGNhbuKAmXQgcmVseSBvbiB0aGUgbGlzdCBwb2ludGVycyByZW1haW5pbmcgY29ycmVjdCwg
c28gd2UgcmVzdGFydCB0aGUgbGlzdCBzY2FuIGFuZCB3ZSB1c2UgdGhlIG9wcy0+c3RhdGVfZmxh
Z19iaXQgdG8gc2lnbmFsIHdoZXRoZXIgb3Igbm90IHN0YXRlIGhhcyBiZWVuIHJlY292ZXJlZCBm
b3IgdGhlIGVudHJ5IGJlaW5nIHNjYW5uZWQuDQo+IA0KPiBidXQgdGhpcyBpcyB0ZXN0ZWQgYXQg
dGhlIHRvcCBvZiB0aGUgbG9vcCBhbmQgYnkgdGhlbiB5b3UgbG9vayBhdA0KPiBsaXN0cycgLT5u
ZXh0IHBvaW50ZXIgd2hpY2ggbWlnaHQgYmUgaW52YWxpZC4NCj4gDQoNCk5vLiBXZSBlbnN1cmUg
d2UgcmVzdGFydCB0aGUgbGlzdCBzY2FuIGlmIHdlIHJlbGVhc2UgdGhlIHNwaW5sb2NrLiBJdOKA
mXMgc2FmZeKApg0KDQoNCg==

