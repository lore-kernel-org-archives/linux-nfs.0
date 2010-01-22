From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] nfs41: cleanup callback code to use __be32 type
Date: Fri, 22 Jan 2010 13:48:36 -0500
Message-ID: <1264186116.30757.8.camel@localhost>
References: <1264179788-5065-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37299 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756261Ab0AVSsi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 13:48:38 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0MImbJP023411
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 10:48:38 -0800 (PST)
In-Reply-To: <1264179788-5065-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-22 at 12:03 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback_proc.c |   15 ++++++++-------
>  fs/nfs/callback_xdr.c  |   30 +++++++++++++++---------------
>  2 files changed, 23 insertions(+), 22 deletions(-)
> 

Thanks! That looks good...

Trond
