Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50067 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab1G3GUG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 02:20:06 -0400
Message-ID: <4E33A288.80403@panasas.com>
Date: Fri, 29 Jul 2011 23:19:52 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        Peng Tao <bergwolf@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHSET 0/6] Patches needed for Stable
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Hi

I've played all day with these commit patches and I came to the conclusion
that we will need all 5 of Peng's commit patches. The minimal set is the first
4 and without the 5th one, is as you pointed out, might be very racy. Let me
explain.

At first I thought all I needed was:
	[PATCH v4 05/27] pnfs: let layoutcommit handle a list of lseg
	[PATCH v4 06/27] pnfs: use lwb as layoutcommit length

But They do not apply as is, and would not work. 
I tried to, instead of taking the creds and lwb from the *header*, take them
from the *first segment*. But this is an ugly hack (I tried, it's really ugly)
and is scary as hell. Because it is code we never tested as opposed to this code
that was the only one I actually tested since before last bakeathon. I would
hate to put such under-tested code in Stable when we will change it hopefully
in this Kernel and is ugly as hell.

So Introducing these two:
	[PATCH v4 03/27] pnfs: save layoutcommit lwb at layout header
	[PATCH v4 04/27] pnfs: save layoutcommit cred at layout header
Just makes sense.

Now also:
	[PATCH v4 07/27] NFS41: save layoutcommit cred in layout header init

Was pointed by you as fixing a potential race, which I agree completely, and
I think it should be just merged with:
	[PATCH 2/6] pnfs: save layoutcommit cred at layout header
Which are the same exact issue only done better

I'm adding two more patches I'll need for Stable which are bug fixes we found
in the large testing we did here after Bakeathon:
	[PATCH 5/6] pnfs-obj: Bug when we are running out of bio
	[PATCH 6/6] pnfs-obj: Fix the comp_index != 0 case

----
So here is the list of patches for stable:

[PATCH 1/6] pnfs: save layoutcommit lwb at layout header
[PATCH 2/6] pnfs: save layoutcommit cred at layout header init
[PATCH 3/6] pnfs: let layoutcommit handle a list of lseg
[PATCH 4/6] pnfs: use lwb as layoutcommit length

	These 4 are Peng's 5 layoutcommit patches. I've combined 
	  [PATCH v4 04/27] pnfs: save layoutcommit cred at layout header
	and
	  [PATCH v4 07/27] NFS41: save layoutcommit cred in layout header init
	Which are just the same issue. And rebased the last one on top of that.
	And added CC: Stable.

[PATCH 5/6] pnfs-obj: Bug when we are running out of bio
[PATCH 6/6] pnfs-obj: Fix the comp_index != 0 case

Thanks
Boaz
