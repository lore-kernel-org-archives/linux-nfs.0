Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57497 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933405Ab3CUOHa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 10:07:30 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 3/3] NFSv4.1: Add a helper pnfs_commit_and_return_layout
Date: Thu, 21 Mar 2013 14:07:05 +0000
Message-ID: <1363874824.3557.9.camel@leira.trondhjem.org>
References: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1363801148-29998-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1363801148-29998-3-git-send-email-Trond.Myklebust@netapp.com>
	 <514AEE40.5040007@panasas.com>
In-Reply-To: <514AEE40.5040007@panasas.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-21 at 13:25 +0200, Boaz Harrosh wrote:
> On 03/20/2013 07:39 PM, Trond Myklebust wrote:
> > In order to be able to safely return the layout in nfs4_proc_setattr,
> > we need to block new uses of the layout, wait for all outstanding
> > users of the layout to complete, commit the layout and then return it.
> > 
> > This patch adds a helper in order to do all this safely.
> > 
> 
> Hi Trond
> 
> It looks like this patchset might actually fix my problem as well.
> 
> I've been super swamped with internal work at Panasas, and never got
> a chance to cleanup and review my experimental fixes. So it looks like
> you bit me to it. Your work looks much better, and deeper then what I
> had. Though one concern I have is that I need those for @stable so my
> change was as minimal as possible, single patch.

I chose to split it into 3 patches because these are really 3 different
problems. The first patch (hopefully) fixes Benny's Oops. The second
fixes a memory leak, while the last one fixes a potential data
corruption.

> I have just arrived back to Israel today, and will only have time to test
> all this Next week. I have just the right setup for this. I understand that
> for you it might be harder because Files-layout does not support segments and
> my deadlock can only happen with two segments and up.
> 
> [BTW: I did not even reviewed the code yet will do ASAP]

Thanks!

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
