From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often
 fails to delete things it just created
Date: Sun, 18 Apr 2010 15:59:10 -0400
Message-ID: <1271620750.8049.3.camel@localhost.localdomain>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	 <1271618484.8049.1.camel@localhost.localdomain>
	 <87vdboa7e0.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54008 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451Ab0DRT71 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Apr 2010 15:59:27 -0400
In-Reply-To: <87vdboa7e0.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-04-18 at 20:27 +0100, Nix wrote: 
> On 18 Apr 2010, Trond Myklebust verbalised:
> 
> > On Sat, 2010-04-17 at 20:43 +0100, Nix wrote: 
> >> I suspect that unlink()ing a not otherwise open file for which writeback
> >> is still underway is causing the files to be sillyrenamed because
> >> writeback is holding them open. If writeback is the only user, they
> >> should surely not be held open: nobody cares what their contents are,
> >> and a lot of code depends on rm -r of directories containing recently-
> >> written-but-still-closed files succeeding.
> >
> > Did you test with commit b80c3cb628f0ebc241b02e38dd028969fb8026a2 (NFS:
> > Ensure that writeback_single_inode() calls write_inode() when syncing)?
> > That fixed the above problem on my setup.
> 
> tip-of-tree includes that commit, and it's still happening for me there.
> (Just verified again.)

Does a 'sync' clear out the sillyrenamed files?

> (The exported filesystem is coming from a box running 2.6.33 atop ext4,
> in case it matters.)

That shouldn't matter.
