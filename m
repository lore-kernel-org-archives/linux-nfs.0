Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45995 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab1G3BJe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 21:09:34 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Fri, 29 Jul 2011 21:09:32 -0400
In-Reply-To: <20110729191341.GC23061@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
	 <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu>
	 <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311988172.16078.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-29 at 15:13 -0400, Jim Rees wrote: 
> Christoph Hellwig wrote:
> 
>   On Fri, Jul 29, 2011 at 02:54:15PM -0400, Jim Rees wrote:
>   > xfstests does require a small patch to work with NFSv4, which I can supply
>   > if anyone is interested.
>   
>   Please send it to xfs@oss.sgi.com with a proper description and signoff.
> 
> I don't have a proper patch, just one that works for me.  But I'll send a
> bug report.  It has to do with the mismatch between nfs and nfs4 mount
> types, so it's not really a xfstests bug.  I think this will fix itself when
> the nfsvers=4 changes fully propagate.
> 
>   It seems like you didn't set up the SCRATCH_DEV variable properly.
> 
> I was just skipping those tests so I could get to the one that fails.  I've
> also tested with the SCRATCH_DEV tests in other runs.
> 
>   > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>   >  kernel:------------[ cut here ]------------
>   > 
>   > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>   >  kernel:invalid opcode: 0000 [#1] SMP 
>   > 
>   > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>   >  kernel:Stack:
>   > 
>   > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>   >  kernel:Call Trace:
>   > 
>   > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
>   
>   Looks like we did find a bug in NFS.
> 
> It kind of looks that way.

Is that reproducible on the upstream kernel, or is it something that is
being introduced by the pNFS blocks code?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

