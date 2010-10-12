Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33834 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757209Ab0JLLJk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 07:09:40 -0400
Received: by qwa26 with SMTP id 26so351444qwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 04:09:40 -0700 (PDT)
From: "P.B.Shelley" <shelleypt@gmail.com>
Date: Tue, 12 Oct 2010 19:09:19 +0800
Message-ID: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
Subject: Question about LAYOUTRETURN stateid
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, all

While reading Linux pnfs code, I have a question in layoutreturn code path.

nfs4_layoutreturn_release() only invalidate layout stateid when
res.lrs_present is FALSE. If it is TRUE, client is supposed to set it
to res.stateid, is it? But I do not see somewhere the layout stateid
is updated. Am I missing something?

5683 static void nfs4_layoutreturn_release(void *calldata)
5684 {
5685         struct nfs4_layoutreturn *lrp = calldata;
5686         struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
5687
5688         dprintk("--> %s return_type %d lo %p\n", __func__,
5689                 lrp->args.return_type, lo);
5690
5691         if (lrp->args.return_type == RETURN_FILE) {
5692                 if (!lrp->res.lrs_present)
5693                         pnfs_invalidate_layout_stateid(lo);
5694                 pnfs_layoutreturn_release(lo, &lrp->args.range);
5695         }
5696         kfree(calldata);
5697         dprintk("<-- %s\n", __func__);
5698 }

-- 
Thanks,
Shelley
