Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:52635 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaCEK7n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 05:59:43 -0500
Received: by mail-vc0-f173.google.com with SMTP id ld13so832846vcb.18
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 02:59:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
	<1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 5 Mar 2014 05:59:43 -0500
Message-ID: <CAHVgHyXmi6Wk37KowDj_oEjysBd4y4DPDpRegsdE-nop=wr_YA@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] NFSv4 fix nfs4_stateid_is_current processing
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond

I did not get any patches with this email.....

-->Andy

On Tue, Mar 4, 2014 at 2:05 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Hi Andy,
>
> Would this be a sufficient fix?
>
> Cheers
>   Trond
>
> Andy Adamson (1):
>   NFSv4.1 Fail data server I/O if stateid represents a lost lock
>
> Trond Myklebust (2):
>   NFSv4: Fix the return value of nfs4_select_rw_stateid
>   NFSv4: Fail the truncate() if the lock/open stateid is invalid
>
>  fs/nfs/nfs4filelayout.c | 10 ++++++----
>  fs/nfs/nfs4proc.c       |  9 ++++++---
>  fs/nfs/nfs4state.c      |  6 ------
>  3 files changed, 12 insertions(+), 13 deletions(-)
>
> --
> 1.8.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
