Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:43159 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbeAZRYd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 12:24:33 -0500
Received: by mail-ua0-f195.google.com with SMTP id i5so749080uai.10
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2018 09:24:33 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 26 Jan 2018 12:24:31 -0500
Message-ID: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
Subject: problem on nfsd doing RDMA write
To: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce/Chuck,

There is a problem with nfsd doing a WRITE of size 4093,4094,4095. To
reproduce, mount with RDMA and do a simple dd "dd if=/dev/zero
of=/mnt/testfile bs=4093 count=1". What happens is that nfsd fails to
parse GETATTR after the WRITE in the compound. It fails the operation
with ERR_OP_ILLEGAL.

The problem happens for the values where XDR round up ends up rounding
up to the page size. I don't know if my fix is the appropriate way to
fix this but with it I don't get the error:

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2c61c6b..a8489c3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1289,11 +1289,12 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compounda

        len = XDR_QUADLEN(write->wr_buflen) << 2;
        if (len >= avail) {
-               int pages;
+               int pages = 0;

                len -= avail;

-               pages = len >> PAGE_SHIFT;
+               if (write->wr_buflen >= PAGE_SIZE)
+                       pages = len >> PAGE_SHIFT;
                argp->pagelist += pages;
                argp->pagelen -= pages * PAGE_SIZE;
                len -= pages * PAGE_SIZE;

So the problem is the using "len" instead of "write->wr_buflen" leads
for the values 4093,4094,4095 that are rounded up to 4096, it makes
pages=1 and the argp->pagelen ends up being a negative value leading
to problems of parsing the GETATTR.

If this looks OK, I can send a patch.
