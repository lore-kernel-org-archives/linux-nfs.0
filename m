Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48735 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262Ab2HIOGP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 10:06:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Idan Kedar <idank@tonian.com>, Boaz Harrosh <bharrosh@panasas.com>,
        "NFS list" <linux-nfs@vger.kernel.org>
CC: Benny Halevy <bhalevy@tonian.com>
Subject: RE: return layout on error, BUG/deadlock
Date: Thu, 9 Aug 2012 14:05:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9380987@SACEXCMBX04-PRD.hq.netapp.com>
References: <CABpMAyL-B9Kqg8O4xxxtj0X8PF7fP4TM+NnLA_Ynhm-_3C6MUg@mail.gmail.com>
In-Reply-To: <CABpMAyL-B9Kqg8O4xxxtj0X8PF7fP4TM+NnLA_Ynhm-_3C6MUg@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Idan Kedar
> Sent: Thursday, August 09, 2012 9:03 AM
> To: Boaz Harrosh; NFS list
> Cc: Benny Halevy
> Subject: return layout on error, BUG/deadlock
> 
> Hi,
> 
> As a result of some experiments, I wanted to see what happens when I
> inject an error (hard coded) to the object layout driver. the patch is at the
> bottom of this mail. the reason I did this is because when I inject errors in my
> modified version of the object layout driver, I get the same BUG Tigran
> reported about yesterday:
> nfs4proc.c:6252 :   BUG_ON(!list_empty(&lo->plh_segs));
> 
> In my modified version (based on kernel 3.3), the bug seems to be that
> pnfs_ld_write_done calls pnfs_return_layout in the error path, even if there
> is in-flight I/O.

That is not a bug. It is an intentional change in order to allow the MDS to fence off the outstanding writes (if it can do so) before we retransmit them as write-through-MDS. Otherwise, you risk races between the outstanding writes-to-DS and the new writes-through-MDS.

See the changelog in the patch that I sent to the list yesterday.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


