Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50547 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2XkY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 18:40:24 -0500
Message-ID: <4ED56BDF.3040900@panasas.com>
Date: Tue, 29 Nov 2011 15:33:51 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Benny Halevy <bhalevy@tonian.com>, Randy Dunlap <rdunlap@xenotime.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>, <linux-next@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au>  <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com>  <4ED4238F.4090407@panasas.com> <4ED4CE58.8090107@tonian.com>  <1322588023.4174.28.camel@lade.trondhjem.org>  <4ED55B3B.9050207@panasas.com>  <1322606193.11286.28.camel@lade.trondhjem.org> <1322606322.11286.30.camel@lade.trondhjem.org>
In-Reply-To: <1322606322.11286.30.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 02:38 PM, Trond Myklebust wrote:
> Should read:
> There is no reason why ORE needs to depend on MISC_FILESYSTEMS. Only
> EXOFS_FS needs that...
> 
> 

OK, thanks

I sent a patch that does that (As reply to Randy).

I'll re-send it as it's own real thing

Thanks
Heart
