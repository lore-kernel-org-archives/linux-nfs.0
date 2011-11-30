Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35420 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757124Ab1K3Qi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 11:38:58 -0500
Message-ID: <4ED65A94.3040303@panasas.com>
Date: Wed, 30 Nov 2011 08:32:20 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>
CC: Randy Dunlap <rdunlap@xenotime.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        NFS list <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>,
        <linux-next@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH v3] ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au> <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com> <4ED4238F.4090407@panasas.com> <4ED56C59.208@panasas.com> <4ED5E9E1.9050709@suse.cz>
In-Reply-To: <4ED5E9E1.9050709@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2011 12:31 AM, Michal Marek wrote:
> 
> I suggest you name it Kconfig.ore. We have a couple of Kconfig.* files
> in the tree, so let's be consistent.
> 

Thanks Michal.

Yes that makes sense. Actually I like it better.
Will change and push

> Michal

Boaz
