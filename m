Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57732 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab1G2TNf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 15:13:35 -0400
Date: Fri, 29 Jul 2011 15:13:41 -0400
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110729191341.GC23061@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
 <20110729185415.GA23061@merit.edu>
 <20110729190133.GA10946@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729190133.GA10946@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:

  On Fri, Jul 29, 2011 at 02:54:15PM -0400, Jim Rees wrote:
  > xfstests does require a small patch to work with NFSv4, which I can supply
  > if anyone is interested.
  
  Please send it to xfs@oss.sgi.com with a proper description and signoff.

I don't have a proper patch, just one that works for me.  But I'll send a
bug report.  It has to do with the mismatch between nfs and nfs4 mount
types, so it's not really a xfstests bug.  I think this will fix itself when
the nfsvers=4 changes fully propagate.

  It seems like you didn't set up the SCRATCH_DEV variable properly.

I was just skipping those tests so I could get to the one that fails.  I've
also tested with the SCRATCH_DEV tests in other runs.

  > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
  >  kernel:------------[ cut here ]------------
  > 
  > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
  >  kernel:invalid opcode: 0000 [#1] SMP 
  > 
  > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
  >  kernel:Stack:
  > 
  > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
  >  kernel:Call Trace:
  > 
  > Message from syslogd@rhcl1 at Jul 29 14:42:05 ...
  
  Looks like we did find a bug in NFS.

It kind of looks that way.
