Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:35138 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793Ab0IBOb1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 10:31:27 -0400
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be mounted yet (try #2)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100902073156.577757b5@notabene>
Date: Thu, 2 Sep 2010 10:30:20 -0400
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <192287B4-8AF0-4A8E-BE9D-8E9A752584B6@oracle.com>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com> <20100901204818.GA10507@fieldses.org> <20100901165605.41f4978d@tlielax.poochiereds.net> <20100902073156.577757b5@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 1, 2010, at 5:31 PM, Neil Brown wrote:

> 
> Hi,
> I was musing about this and thought I would share my musings - not to be
> taken too seriously unless they resonate with you.
> 
> If rpc.nfsd is mounting /proc/fs/nfsd, should it also be starting rpc.statd,
> which should be running before nfsd is started?
> Should it 'exportfs -av' too?
> 
> Should mount.nfs be mounting /var/lib/nfs/rpc_pipefs too?
> It already runs statd as requimred, which in-turn runs sm-notify, though it
> is really best to run that much earlier.
> 
> How far do we really want to go with this "just do the right thing" approach?
> 
> Should "rpc.nfsd" be a replacement for /etc/init.d/nfs-kernel-server or
> whatever your favourite distro calls it?  Or should it just be a tool for
> managing the nfsd threads?
> 
> 
> I could imagine that it would be OK to add a '-L' flag to say 'use legacy
> interface' and have rpc.nfsd fail noisily if nfsdfs wasn't mounted, and -L
> wasn't given.
> 
> I could imagine that if protocol options were specified with -L, that would
> be an error.
> 
> And if protocol options are specified which differ from what is currently
> in-force, and there are active threads, rpc.nfsd could:
>    reduce the number of threads to 0
>    change the protocol options
>    restore the number of threads
> 
> 
> 
> I think it is (long past) time to deprecate the legacy support in the kernel
> at least.  I suggest we add a printk to sys_nfsservctl to warn of pending
> deprecation, and probably add an entry to
> Documentation/feature-removal-schedule.txt.
> Aim for removing it all in 2.6.40 ?? and make it a CONFIG option before that.

Based on my experience with crabby packagers of nfs-utils, I think a long term plan is a good idea.  Warnings of deprecation, for now, is an appropriate first step.  And, leaving ample time for people to take the hint is good.  .40 gives us a year.  .44 gives us two years.  Unless it becomes terribly unwieldy, two years is probably a little better, given the glacial rate at which some of the outlying distributions pick up new features.

-- 
chuck[dot]lever[at]oracle[dot]com




