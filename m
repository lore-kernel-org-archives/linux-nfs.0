Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57530 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952Ab2EDSOP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 May 2012 14:14:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [patch] NFS: silence Sparse warning about a non-ANSI declaration
Date: Fri, 4 May 2012 18:14:14 +0000
Message-ID: <1336155258.2582.2.camel@lade.trondhjem.org>
References: <20120504174017.GB18827@elgon.mountain>
In-Reply-To: <20120504174017.GB18827@elgon.mountain>
Content-Type: multipart/mixed;
	boundary="_002_133615525825822camelladetrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_133615525825822camelladetrondhjemorg_
Content-Type: text/plain; charset="utf-8"
Content-ID: <A59367C8082A8B4BB79D7EA9E3E02B07@tahoe.netapp.com>
Content-Transfer-Encoding: base64

T24gRnJpLCAyMDEyLTA1LTA0IGF0IDIwOjQwICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiBTcGFyc2UgY29tcGxhaW5zIGJlY2F1c2Ugd2l0aG91dCB0aGUgInZvaWQiLCBpdCBtZWFucyB0
aGF0IHRoZSBmdW5jdGlvbg0KPiB0YWtlcyBhIHZhcmlhYmxlIG51bWJlciBvZiBhcmd1bWVudHMu
DQo+IA0KPiBmcy9uZnMvcmVhZC5jOjM4OjQzOiB3YXJuaW5nOiBub24tQU5TSSBmdW5jdGlvbiBk
ZWNsYXJhdGlvbiBvZiBmdW5jdGlvbg0KPiAJJ25mc19yZWFkaGRyX2FsbG9jJw0KPiANCj4gU2ln
bmVkLW9mZi1ieTogRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPg0KPiAN
Cj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9yZWFkLmMgYi9mcy9uZnMvcmVhZC5jDQo+IGluZGV4IDM3
YzllYjIuLmYyM2NmMjUgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9yZWFkLmMNCj4gKysrIGIvZnMv
bmZzL3JlYWQuYw0KPiBAQCAtMzUsNyArMzUsNyBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IG5mc19w
Z2lvX2NvbXBsZXRpb25fb3BzIG5mc19hc3luY19yZWFkX2NvbXBsZXRpb25fb3BzOw0KPiAgDQo+
ICBzdGF0aWMgc3RydWN0IGttZW1fY2FjaGUgKm5mc19yZGF0YV9jYWNoZXA7DQo+ICANCj4gLXN0
cnVjdCBuZnNfcmVhZF9oZWFkZXIgKm5mc19yZWFkaGRyX2FsbG9jKCkNCj4gK3N0cnVjdCBuZnNf
cmVhZF9oZWFkZXIgKm5mc19yZWFkaGRyX2FsbG9jKHZvaWQpDQo+ICB7DQo+ICAJc3RydWN0IG5m
c19yZWFkX2hlYWRlciAqcmhkcjsNCj4gIA0KDQpZZXMuIEkgZm91bmQgdGhhdCB0b2dldGhlciB3
aXRoIGEgY291cGxlIG9mICJzaG91bGQgdGhpcyBiZSBkZWNsYXJlZA0Kc3RhdGljPyIgd2Fybmlu
Z3MgZWFybGllciB0b2RheS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cu
bmV0YXBwLmNvbQ0KDQo=

--_002_133615525825822camelladetrondhjemorg_
Content-Type: message/rfc822
Content-Disposition: attachment;
	creation-date="Fri, 04 May 2012 18:14:14 GMT";
	modification-date="Fri, 04 May 2012 18:14:14 GMT"
Content-ID: <404CBC77F0665140BB6813B406BDAF6E@tahoe.netapp.com>

Received: from smtp2.corp.netapp.com (10.57.159.114) by
 VMWEXCEHT01-PRD.hq.netapp.com (10.106.76.239) with Microsoft SMTP Server id
 14.2.247.3; Fri, 4 May 2012 11:09:23 -0700
Received: from lade.trondhjem.org.com ([10.63.232.194])	by
 smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q44I9JKt007249;
 Fri, 4 May 2012 11:09:22 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Fred Isaman <iisaman@netapp.com>, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 2/2] NFS: Fix sparse warnings
Date: Fri, 4 May 2012 14:09:19 -0400
Message-ID: <1336154959-10705-2-git-send-email-Trond.Myklebust@netapp.com>
X-Mailer: git-send-email 1.7.7.6
In-Reply-To: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1336154959-10705-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain
Return-Path: Trond.Myklebust@netapp.com
X-MS-Exchange-Organization-AuthSource: vmwexceht01-prd.hq.netapp.com
X-MS-Exchange-Organization-AuthAs: Anonymous
X-MS-Exchange-Organization-AVStamp-Mailbox: MSFTFF;1;0;0 0 0
X-Evolution-Source: 1330275140.5304.5@lade.trondhjem.org
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0

Fix the following sparse warnings:

fs/nfs/direct.c:221:6: warning: symbol 'nfs_direct_readpage_release' was
not declared. Should it be static?
fs/nfs/read.c:38:43: warning: non-ANSI function declaration of function
'nfs_readhdr_alloc'
fs/nfs/objlayout/objio_osd.c:214:5: warning: symbol '__alloc_objio_seg'
was not declared. Should it be static?

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/direct.c              |    2 +-
 fs/nfs/objlayout/objio_osd.c |    2 +-
 fs/nfs/read.c                |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index dca9c81..257d009 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -218,7 +218,7 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 	nfs_direct_req_release(dreq);
 }
 
-void nfs_direct_readpage_release(struct nfs_page *req)
+static void nfs_direct_readpage_release(struct nfs_page *req)
 {
 	dprintk("NFS: direct read done (%s/%lld %d@%lld)\n",
 		req->wb_context->dentry->d_inode->i_sb->s_id,
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index fbf4874..b47277b 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -211,7 +211,7 @@ static void copy_single_comp(struct ore_components *oc, unsigned c,
 	memcpy(ocomp->cred, src_comp->oc_cap.cred, sizeof(ocomp->cred));
 }
 
-int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
+static int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
 		       struct objio_segment **pseg)
 {
 /*	This is the in memory structure of the objio_segment
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 37c9eb2..f23cf25 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -35,7 +35,7 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
 
 static struct kmem_cache *nfs_rdata_cachep;
 
-struct nfs_read_header *nfs_readhdr_alloc()
+struct nfs_read_header *nfs_readhdr_alloc(void)
 {
 	struct nfs_read_header *rhdr;
 
-- 
1.7.7.6


--_002_133615525825822camelladetrondhjemorg_--
