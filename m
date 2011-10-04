Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:53769 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567Ab1JDM23 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 08:28:29 -0400
Message-ID: <4E8AFBBD.1090700@panasas.com>
Date: Tue, 4 Oct 2011 14:27:41 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 16/19] pnfs-obj: Rename objlayout_io_state => objlayout_io_res
References: <4E8ADEDA.4050709@panasas.com> <1317724560-27795-1-git-send-email-bharrosh@panasas.com> <20111004122019.GA2946@umich.edu>
In-Reply-To: <20111004122019.GA2946@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/04/2011 02:20 PM, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   * All instances of objlayout_io_state => objlayout_io_res
>   * All instances of state => oir;
>   * All instances of ol_state => oir;
>   
>   Big but nothing to it
>   
>   Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> 
> You have trailing whitespace here:
> 
>   + * objlayout_{read,write}_done 

Thanks! of course that was the very last change I did, to add that
comment. Will repost

Thanks
Boaz

