Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:33148 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab3KTJaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 04:30:10 -0500
Received: by mail-vc0-f171.google.com with SMTP id ik5so163741vcb.16
        for <linux-nfs@vger.kernel.org>; Wed, 20 Nov 2013 01:30:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384897797.45997.1.camel@leira.trondhjem.org>
References: <1384551376-8734-1-git-send-email-andros@netapp.com> <1384897797.45997.1.camel@leira.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 20 Nov 2013 10:29:49 +0100
Message-ID: <CAJ75kXahPFSMsec27Eu2cR2N7cNrv_cwtL9cN3At5RNU1fZC-Q@mail.gmail.com>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session errors
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Tue, Nov 19, 2013 at 10:49 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> There is a second patch that goes with this problem. Please see the
> following attachment.

ba64b36 NFSv4: Update list of irrecoverable errors on DELEGRETURN
is cc'ed for stable

If these two patches are connected, why the first one:
d3b173a NFSv4 wait on recovery for async session errors
is not cc'ed for stable as well?

For example in stable v3.10.x we currently have:

        case -NFS4ERR_SEQ_MISORDERED:
            dprintk("%s ERROR %d, Reset session\n", __func__,
                task->tk_status);
            nfs4_schedule_session_recovery(clp->cl_session, task->tk_status);
            task->tk_status = 0;
            return -EAGAIN;

but with the last pacthes we now have in mainline:

        case -NFS4ERR_SEQ_MISORDERED:
            dprintk("%s ERROR: %d Reset session\n", __func__,
                errorcode);
            nfs4_schedule_session_recovery(clp->cl_session, errorcode);
            goto wait_on_recovery;


and this was orignally change because of commit
f1478c1 NFS: Re-use exit code in nfs4_async_handle_error()

The result in stable v3.10.x doesn't really make sense to me. Did I
missed something?

Regards,
-- 
William
