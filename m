From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe
	rpciod	deadlock?
Date: Mon, 14 Jan 2008 14:31:48 -0500
Message-ID: <1200339108.7470.45.camel@heimdal.trondhjem.org>
References: <18310.37731.29874.582772@notabene.brown>
	 <1200004896.13775.27.camel@heimdal.trondhjem.org>
	 <478BB194.3090103@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:36540 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbYANTbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 14:31:53 -0500
In-Reply-To: <478BB194.3090103@uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-14 at 14:01 -0500, Benjamin Coddington wrote:
> Trond Myklebust wrote:
> 
> > I'm surprised that we can get into this state, though. How is
> > sys_umount() able to exit with either readaheads or writebacks still
> > pending? Is this perhaps occurring on a lazy umount?
> 
> Should we be submitting async tasks in gss_destroying_context?  I get 
> this problem on umount with 3 or more cached GSS creds -- and end up 
> blocked in rpciod_down - destroy_workqueue..

That shouldn't be the case in standard 2.6.22 unless you've also applied
the NFS_ALL patches. In that case, there is a fix (which has also been
applied to mainline) in

 http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc1/linux-2.6.23-001-fix_rpciod_down_race.dif

Cheers
  Trond

