Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19064 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779Ab1K2RnI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 12:43:08 -0500
Message-ID: <1322588583.4174.34.camel@lade.trondhjem.org>
Subject: Re: [PATCH 4/4] pnfsblock: do ask for layout in pg_init
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Date: Tue, 29 Nov 2011 12:43:03 -0500
In-Reply-To: <CA+a=Yy7wbcYsBQ+tuMR86+fiRn8xNcZxFvJTFOEsWqrJKRm7sQ@mail.gmail.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	 <1322887965-2938-5-git-send-email-bergwolf@gmail.com>
	 <1322584823.4174.15.camel@lade.trondhjem.org>
	 <CA+a=Yy7wbcYsBQ+tuMR86+fiRn8xNcZxFvJTFOEsWqrJKRm7sQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-11-30 at 01:25 +0800, Peng Tao wrote: 
> On Wed, Nov 30, 2011 at 12:40 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Fri, 2011-12-02 at 20:52 -0800, Peng Tao wrote:
> >> Asking for layout in pg_init will always make client ask for only 4KB
> >> layout in every layoutget. This way, client drops the IO size information
> >> that is meaningful for MDS in handing out layout.
> >>
> >> In stead, if layout is not find in cache, do not send layoutget
> >> at once. Wait until before issuing IO in pnfs_do_multiple_reads/writes
> >> because that is where we know the real size of current IO. By telling the
> >> real IO size to MDS, MDS will have a better chance to give proper layout.
> >
> > Why can't you just split pnfs_update_layout() into 2 sub-functions
> > instead of duplicating it in private block code?
> Because I wanted to differentiate between no layout header and no
> cached lseg, where the pnfs_update_layout() interface is not enough to
> tell the difference. Of course I can put these all into generic layer.
> I will update the patchset to do it.
> 
> >
> > Then call layoutget in your pg_doio() callback instead of adding a
> > redundant pnfs_update_layout to
> > pnfs_do_multiple_reads/pnfs_do_multiple_writes...
> I have considered it before but using private pg_doio() means we will
> have as much duplication of pnfs_generic_pg_read/writepages.

Why? All you need to do is send the layoutget, and then call the
existing pnfs_generic_pg_read/writepages?

The difference here is that you're adding that step into
pnfs_generic_pg_read/writepages in patch 3/4. Basically you are adding
block-specific code into an otherwise generic function instead of doing
it cleanly in the block-specific callbacks.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

