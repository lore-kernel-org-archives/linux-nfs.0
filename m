Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34107 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246Ab1GVT7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 15:59:12 -0400
In-Reply-To: <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com> <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Date: Fri, 22 Jul 2011 21:58:51 +0200
Message-ID: <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com>
Subject: Re: [PATCH 10/13] net: add paged frag destructor to skb_fill_page_desc()
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
        devel@open-fcoe.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

MjAxMS83LzIyIElhbiBDYW1wYmVsbCA8aWFuLmNhbXBiZWxsQGNpdHJpeC5jb20+Ogo+IGRpZmYg
LS1naXQgYS9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oIGIvaW5jbHVkZS9saW51eC9za2J1ZmYuaAo+
IGluZGV4IDk4MThmZTIuLmZhZWU4ZDMgMTAwNjQ0Cj4gLS0tIGEvaW5jbHVkZS9saW51eC9za2J1
ZmYuaAo+ICsrKyBiL2luY2x1ZGUvbGludXgvc2tidWZmLmgKPiBAQCAtMTEzNCwxMiArMTEzNCwx
NCBAQCBzdGF0aWMgaW5saW5lIGludCBza2JfcGFnZWxlbihjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiKQo+IMKgKiBEb2VzIG5vdCB0YWtlIGFueSBhZGRpdGlvbmFsIHJlZmVyZW5jZSBvbiB0aGUg
ZnJhZ21lbnQuCj4gwqAqLwo+IMKgc3RhdGljIGlubGluZSB2b2lkIF9fc2tiX2ZpbGxfcGFnZV9k
ZXNjKHN0cnVjdCBza19idWZmICpza2IsIGludCBpLAo+IC0gwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgc3RydWN0IHBhZ2UgKnBhZ2UsIGlu
dCBvZmYsIGludCBzaXplKQo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgc3RydWN0IHBhZ2UgKnBhZ2UsCj4gKyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzdHJ1Y3Qgc2tiX2Zy
YWdfZGVzdHJ1Y3RvciAqZGVzdHJveSwKPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGludCBvZmYsIGludCBzaXplKQo+IMKgewo+IMKg
IMKgIMKgIMKgc2tiX2ZyYWdfdCAqZnJhZyA9ICZza2Jfc2hpbmZvKHNrYiktPmZyYWdzW2ldOwo+
Cj4gwqAgwqAgwqAgwqBmcmFnLT5wYWdlLnAgwqAgwqAgwqAgwqAgwqAgwqAgwqA9IHBhZ2U7Cj4g
LSDCoCDCoCDCoCBmcmFnLT5wYWdlLmRlc3RydWN0b3IgwqAgwqAgPSBOVUxMOwo+ICsgwqAgwqAg
wqAgZnJhZy0+cGFnZS5kZXN0cnVjdG9yIMKgIMKgID0gZGVzdHJveTsKPiDCoCDCoCDCoCDCoGZy
YWctPnBhZ2Vfb2Zmc2V0IMKgIMKgIMKgIMKgID0gb2ZmOwo+IMKgIMKgIMKgIMKgZnJhZy0+c2l6
ZSDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoD0gc2l6ZTsKPiDCoH0KCllvdSBjb3VsZCBqdXN0IHJl
bmFtZSB0aGlzIGZ1bmN0aW9uIHRvIGUuZy4KX19za2JfZmlsbF9mcmFnaWxlX3BhZ2VfZGVzYygp
IChvciB3aGF0ZXZlciBuYW1lKSBhZGQgYW4gaW5saW5lCndyYXBwZXIgY2FsbGluZyBpdCB3aXRo
IGRlc3Ryb3kgPT0gTlVMTC4gVGhpcyB3aWxsIGF2b2lkIHRvdWNoaW5nIGFsbAp0aG9zZSBkcml2
ZXJzIHdoaWNoIHdvbid0IGV2ZXIgbmVlZCB0aGlzIGZ1bmN0aW9uYWxpdHkuCgpCZXN0IFJlZ2Fy
ZHMsCk1pY2hhxYIgTWlyb3PFgmF3CgTvv717Lm7vv70r77+977+977+977+977+977+977+9KyXv
v73vv71sendt77+977+9Yu+/veunsu+/ve+/vXLvv73vv716WO+/ve+/vRnfsinvv73vv73vv713
Kh9qZ++/ve+/ve+/vR7vv73vv73vv73vv73vv73domov77+977+977+9eu+/vd6W77+977+9Mu+/
vd6Z77+977+977+9Ju+/vSnfoe+/vWHvv73vv71/77+977+9Hu+/vUfvv73vv73vv71o77+9D++/
vWo6K3bvv73vv73vv71377+92aU=
