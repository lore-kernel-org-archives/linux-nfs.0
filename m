Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52795 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab0JLNL5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 09:11:57 -0400
Received: by bwz15 with SMTP id 15so2376330bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 06:11:56 -0700 (PDT)
In-Reply-To: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
References: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
Date: Tue, 12 Oct 2010 09:11:53 -0400
Message-ID: <AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+@mail.gmail.com>
Subject: Re: Question about LAYOUTRETURN stateid
From: Fred Isaman <iisaman@netapp.com>
To: "P.B.Shelley" <shelleypt@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 7:09 AM, P.B.Shelley <shelleypt@gmail.com> wrote:
> Hi, all
>
> While reading Linux pnfs code, I have a question in layoutreturn code path.
>
> nfs4_layoutreturn_release() only invalidate layout stateid when
> res.lrs_present is FALSE. If it is TRUE, client is supposed to set it
> to res.stateid, is it? But I do not see somewhere the layout stateid
> is updated. Am I missing something?
>

No, you are not missing anything.  that is a bug.

Fred

> 5683 static void nfs4_layoutreturn_release(void *calldata)
> 5684 {
> 5685         struct nfs4_layoutreturn *lrp = calldata;
> 5686         struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
> 5687
> 5688         dprintk("--> %s return_type %d lo %p\n", __func__,
> 5689                 lrp->args.return_type, lo);
> 5690
> 5691         if (lrp->args.return_type == RETURN_FILE) {
> 5692                 if (!lrp->res.lrs_present)
> 5693                         pnfs_invalidate_layout_stateid(lo);
> 5694                 pnfs_layoutreturn_release(lo, &lrp->args.range);
> 5695         }
> 5696         kfree(calldata);
> 5697         dprintk("<-- %s\n", __func__);
> 5698 }
>
> --
> Thanks,
> Shelley
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
