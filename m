Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:45670 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933753AbcIUQjc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2016 12:39:32 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Schumaker Anna <Anna.Schumaker@netapp.com>
CC: Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH v6 12/29] NFSv4.1: Allow revoked stateids to skip the call
 to TEST_STATEID
Date: Wed, 21 Sep 2016 16:39:23 +0000
Message-ID: <4DB78504-6883-47DE-9FB2-DD9014266450@primarydata.com>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-2-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-3-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-4-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-5-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-6-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-7-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-8-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-9-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-10-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-11-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-12-git-send-email-trond.myklebust@primarydata.com>
 <1474390571-17106-13-git-send-email-trond.myklebust@primarydata.com>
 <ad05aaa3-ac5d-eda2-9218-942423d43a0b@Netapp.com>
In-Reply-To: <ad05aaa3-ac5d-eda2-9218-942423d43a0b@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIFNlcCAyMSwgMjAxNiwgYXQgMTI6MDMsIEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVt
YWtlckBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+IEhpIFRyb25kLA0KPiANCj4gT24gMDkvMjAv
MjAxNiAxMjo1NSBQTSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPj4gSW4gc29tZSBjYXNlcyAo
ZS5nLiB3aGVuIHRoZSBTRVE0X1NUQVRVU19FWFBJUkVEX0FMTF9TVEFURV9SRVZPS0VEIHNlcXVl
bmNlDQo+PiBmbGFnIGlzIHNldCkgd2UgbWF5IGFscmVhZHkga25vdyB0aGF0IHRoZSBzdGF0ZWlk
IHdhcyByZXZva2VkIGFuZCB0aGF0IHRoZQ0KPj4gb25seSB2YWxpZCBvcGVyYXRpb24gd2UgY2Fu
IGNhbGwgaXMgRlJFRV9TVEFURUlELiBJbiB0aG9zZSBjYXNlcywgYWxsb3cNCj4+IHRoZSBzdGF0
ZWlkIHRvIGNhcnJ5IHRoZSBpbmZvcm1hdGlvbiBpbiB0aGUgdHlwZSBmaWVsZCwgc28gdGhhdCB3
ZSBza2lwDQo+PiB0aGUgcmVkdW5kYW50IGNhbGwgdG8gVEVTVF9TVEFURUlELg0KPiANCj4gV291
bGQgeW91IGxpa2UgdG8gYWRkIGEgU2lnbmVkLW9mZi1ieSB0byB0aGlzIHBhdGNoPyA6KQ0KDQpV
bW3igKYuIFllc+KApiBTb3JyeS4uLg0KDQo=

