Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48921 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab1CDQoa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 11:44:30 -0500
From: Neil Horman <nhorman@tuxdriver.com>
To: linux-nfs@vger.kernel.org
Cc: Neil Horman <nhorman@tuxdriver.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not allocated from the slab
Date: Fri,  4 Mar 2011 11:44:13 -0500
Message-Id: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This oops was reported recently:

 <IRQ>  [<ffffffff800ca161>] bad_page+0x69/0x91
  [<ffffffff8000b8ae>] free_hot_cold_page+0x81/0x144
  [<ffffffff8022f28a>] skb_release_data+0x5f/0x98
  [<ffffffff80028b88>] __kfree_skb+0x11/0x1a
  [<ffffffff800243b8>] tcp_ack+0x6a3/0x1868
  [<ffffffff8001bff4>] tcp_rcv_established+0x7a6/0x8b9
  [<ffffffff8003b684>] tcp_v4_do_rcv+0x2a/0x2fa
  [<ffffffff8002730e>] tcp_v4_rcv+0x9a2/0x9f6
  [<ffffffff80099b45>] do_timer+0x2df/0x52c
  [<ffffffff8003495c>] ip_local_deliver+0x19d/0x263
  [<ffffffff80035ab8>] ip_rcv+0x539/0x57c
  [<ffffffff80020ab6>] netif_receive_skb+0x470/0x49f
  [<ffffffff883190b5>] :virtio_net:virtnet_poll+0x46b/0x5c5
  [<ffffffff8000c979>] net_rx_action+0xac/0x1b3
  [<ffffffff80012464>] __do_softirq+0x89/0x133
  [<ffffffff8005e2fc>] call_softirq+0x1c/0x28
  [<ffffffff8006d5f5>] do_softirq+0x2c/0x7d
  [<ffffffff8006d485>] do_IRQ+0xec/0xf5
  [<ffffffff8006bdb5>] default_idle+0x0/0x50
  [<ffffffff8005d615>] ret_from_intr+0x0/0xa
  <EOI>  [<ffffffff8006bdde>] default_idle+0x29/0x50
  [<ffffffff800492fd>] cpu_idle+0x95/0xb8
  [<ffffffff80461807>] start_kernel+0x220/0x225
  [<ffffffff8046122f>] _sinittext+0x22f/0x236

It occurs, because an skb with a fraglist was freed from the tcp retransmit
queue when it was acked, but a page on that fraglist had PG_Slab set (indicating
it was allocated from the Slab allocator (which means the free path above can't
safely free it via put_page)

We tracked this back to an nfsv4 setacl operation, in which the nfs code
attempted to fill convert the passed in buffer to an array of pages in
__nfs4_proc_set_acl, which gets used by the skb->frags list in xs_sendpages.
__nfs4_proc_set_acl just converts each page in the buffer to a page struct via
virt_to_page, but the vfs allocates the buffer via kmalloc, meaning the PG_slab
bit is set.  We can't create a buffer with kmalloc and free it later in the tcp
ack path with put_page, so we need to either:

1) ensure that when we create the list of pages, no page struct has PG_Slab set
or
2) not use a page list to send this data

Given that these buffers can be multiple pages and arbitrarily sized, I think
(1) is the right way to go.  I've written the below patch to allocate a page
from the buddy allocator directly and copy the data over to it.  This ensures
that we have a put_page free-able page for every entry that winds up on an skb
frag list, so it can be safely freed when the frame is acked.  We do a put page
on each entry after the rpc_call_sync call so as to drop our own reference count
to the page, leaving only the ref count taken by tcp_sendpages.  This way the
data will be properly freed when the ack comes in

Successfully tested by myself to solve the above oops.

Note, as this is the result of a setacl operation that exceeded a page of data,
I think this amounts to a local DOS triggerable by an uprivlidged user, so I'm
CCing security on this as well.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: security@kernel.org
CC: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c |   42 ++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78936a8..e4bd9b5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -51,6 +51,7 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
+#include <linux/mm.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -3252,6 +3253,36 @@ static void buf_to_pages(const void *buf, size_t buflen,
 	}
 }
 
+static int buf_to_pages_noslab(const void *buf, size_t buflen,
+		struct page **pages, unsigned int *pgbase)
+{
+	const void *p = buf;
+	struct page *page, *newpage, **spages;
+	int rc = -ENOMEM;
+
+	spages = pages;
+	*pgbase = offset_in_page(buf);
+	p -= *pgbase;
+	while (p < buf + buflen) {
+		page = virt_to_page(p);
+		newpage = alloc_page(GFP_KERNEL);
+		if (!newpage)
+			goto unwind;
+		memcpy(page_address(newpage), page_address(page),
+		       PAGE_CACHE_SIZE);
+		*(pages++) = newpage;
+		p += PAGE_CACHE_SIZE;
+	}
+
+	rc = 0;
+	return rc;
+
+unwind:
+	while (*spages != NULL)
+		__free_page(*(spages++));
+	return rc;
+}
+
 struct nfs4_cached_acl {
 	int cached;
 	size_t len;
@@ -3420,13 +3451,20 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 	};
-	int ret;
+	int ret, i;
 
 	if (!nfs4_server_supports_acls(server))
 		return -EOPNOTSUPP;
+	memset(pages, 0, sizeof(struct page *) * NFS4ACL_MAXPAGES);
+	ret = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
+	if (ret)
+		return ret;
 	nfs_inode_return_delegation(inode);
-	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
+
+	for (i = 0; pages[i] != NULL; i++)
+		put_page(pages[i]);
+
 	/*
 	 * Acl update can result in inode attribute update.
 	 * so mark the attribute cache invalid.
-- 
1.7.4

