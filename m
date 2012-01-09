Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47409 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab2AIIJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 03:09:15 -0500
Received: by eaad14 with SMTP id d14so1882430eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 00:09:14 -0800 (PST)
Message-ID: <4F0AA0A5.80606@tonian.com>
Date: Mon, 09 Jan 2012 10:09:09 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCHSET 0/2] pnfs-obj: Important BUG fixing also for @Stable
References: <4F06A18E.4010706@panasas.com>
In-Reply-To: <4F06A18E.4010706@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes included in pnfs-all-3.2-2012-01-08

Thanks,

Benny

On 2012-01-06 09:23, Boaz Harrosh wrote:
> Hi Trond
> 
> I'm sending in two patches that fixes a bad hung, memory leak, a WARN_ON
> and plain wrong protocol handling. In regard to objlayout error handling.
> These are also aimed at Stable@ for the 3.2 Kernel.
> (Actually these bugs are in since 3.0, I might produce another version
>  for 3.[1,0] after these go in)
> 
> I have simulated errors at various layers, reads and writes, in combination
> of different tests, and they work as I expect. .i.e IO continues to MDS and
> oblayout is returned on error.
> 
> Please include these patches for 3.3 and they can go to Stable@ for 3.2
> has well.
> 
> list of patches:
> [PATCH 1/2] pnfs-obj: pNFS errors are communicated on iodata->pnfs_error
> 
> 	This is just a stupidity and neglect. Benny can you understand
> 	what happened here?
> 
> [PATCH 2/2] pnfs-obj: Must return layout on IO error
> 
> 	This patch is mainly for pnfs.c but I think it is very simple
> 	and totally not affecting anybody but objlayout. So it should
> 	be safe, and does fixes my main problem.
> 	Fred please review?
> 
> Please Review
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
