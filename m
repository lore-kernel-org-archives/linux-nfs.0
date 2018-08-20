Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr660047.outbound.protection.outlook.com ([40.107.66.47]:12672
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726250AbeHTQGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Aug 2018 12:06:47 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "trondmy@hammerspace.com" <trondmy@hammerspace.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>
Subject: Re: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly
 coupled DSes
Date: Mon, 20 Aug 2018 12:51:14 +0000
Message-ID: <YTOPR0101MB18202768E081C824A96ECC0ADD320@YTOPR0101MB1820.CANPRD01.PROD.OUTLOOK.COM>
References: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
In-Reply-To: <20180820065608.11860-1-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks. I'll test this later to-day. (I did a slightly more complex version
of the fix outside of the ff_layout_get_ds_cred() call, but yours is
definitely simpler).

There is also the "stateid", which I believe is supposed to be the one in
the layout for the tightly coupled case (for NFSv4 I/O ops to the DS).
My patch is here and has the changes for stated as well as cred.

http://people.freebsd.org/~rmacklem/flexfile.patch
(Sorry, I don't know git;-)

Thanks for doing this and I'll post if my testing finds problems, rick


________________________________________
From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on behalf of Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sent: Monday, August 20, 2018 2:56:08 AM
To: linux-nfs@vger.kernel.org
Cc: trondmy@hammerspace.com; Anna.Schumaker@Netapp.com; Tigran Mkrtchyan
Subject: [PATCH] nfs4: flex_file: ignore synthetic uid/gid for tightly coupled DSes

for tightly coupled DSes client must ignore provided synthetic uid and
gid as stated in draft-ietf-nfsv4-flex-files-19#section-5.1.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d62279d3fc5d..290625cfd369 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -452,7 +452,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
        struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
        struct rpc_cred *cred;

-       if (mirror) {
+       if (mirror && !mirror->mirror_ds->ds_versions[0].tightly_coupled) {
                cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
                if (!cred)
                        cred = get_rpccred(mdscred);
--
2.17.1
