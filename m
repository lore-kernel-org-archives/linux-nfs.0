Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34192 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848Ab0IAVcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 17:32:05 -0400
Date: Thu, 2 Sep 2010 07:31:56 +1000
From: Neil Brown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100902073156.577757b5@notabene>
In-Reply-To: <20100901165605.41f4978d@tlielax.poochiereds.net>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
	<20100901204818.GA10507@fieldses.org>
	<20100901165605.41f4978d@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi,
 I was musing about this and thought I would share my musings - not to be
 taken too seriously unless they resonate with you.

 If rpc.nfsd is mounting /proc/fs/nfsd, should it also be starting rpc.statd,
 which should be running before nfsd is started?
 Should it 'exportfs -av' too?

 Should mount.nfs be mounting /var/lib/nfs/rpc_pipefs too?
 It already runs statd as requimred, which in-turn runs sm-notify, though it
 is really best to run that much earlier.

 How far do we really want to go with this "just do the right thing" approach?

 Should "rpc.nfsd" be a replacement for /etc/init.d/nfs-kernel-server or
 whatever your favourite distro calls it?  Or should it just be a tool for
 managing the nfsd threads?


 I could imagine that it would be OK to add a '-L' flag to say 'use legacy
 interface' and have rpc.nfsd fail noisily if nfsdfs wasn't mounted, and -L
 wasn't given.

 I could imagine that if protocol options were specified with -L, that would
 be an error.

 And if protocol options are specified which differ from what is currently
 in-force, and there are active threads, rpc.nfsd could:
    reduce the number of threads to 0
    change the protocol options
    restore the number of threads



 I think it is (long past) time to deprecate the legacy support in the kernel
 at least.  I suggest we add a printk to sys_nfsservctl to warn of pending
 deprecation, and probably add an entry to
 Documentation/feature-removal-schedule.txt.
 Aim for removing it all in 2.6.40 ?? and make it a CONFIG option before that.

 BTW, the 'new' cache has was added during 2.5 - definitely before Jan 2003.
 So the old stuff really is quite old now.

NeilBrown
