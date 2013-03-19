Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:21189 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932483Ab3CSRmp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 13:42:45 -0400
Received: from vmwexceht05-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r2JHgLmn024492
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 10:42:21 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Date: Tue, 19 Mar 2013 17:42:21 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286DCE9C@SACEXCMBX04-PRD.hq.netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
 <A0468A45-044E-45E1-8256-38AD5814B6D8@netapp.com>
In-Reply-To: <A0468A45-044E-45E1-8256-38AD5814B6D8@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Adamson, Andy
> Sent: Tuesday, March 19, 2013 1:30 PM
> To: Myklebust, Trond
> Cc: <linux-nfs@vger.kernel.org>
> Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
> 
> Hi Trond
> 
> You need to declare the new NFS_OPEN_CLAIMs.
> 
> From: Andy Adamson <andros@netapp.com>
> Date: Tue, 19 Mar 2013 13:03:36 -0400
> Subject: [PATCH 17/21] NFSv4.1 declare new NFS4_OPEN_CLAIM * FH
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/nfs4.h |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h index
> 7552bb5..380d944 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -388,7 +388,10 @@ enum open_claim_type4 {
>         NFS4_OPEN_CLAIM_NULL = 0,
>         NFS4_OPEN_CLAIM_PREVIOUS = 1,
>         NFS4_OPEN_CLAIM_DELEGATE_CUR = 2,
> -       NFS4_OPEN_CLAIM_DELEGATE_PREV = 3
> +       NFS4_OPEN_CLAIM_DELEGATE_PREV = 3,
> +       NFS4_OPEN_CLAIM_FH = 4,
> +       NFS4_OPEN_CLAIM_DELEG_CUR_FH = 5,
> +       NFS4_OPEN_CLAIM_DELEG_PREV_FH = 6
>  };
> 
>  enum opentype4 {
> 
> -->Andy

See commit 8b289b2c2355c3bea75f3e499b4aa251a3191382 (nfsd4: implement new 4.1 open reclaim types). It was upstreamed in Linux-3.2.

Cheers
  Trond
