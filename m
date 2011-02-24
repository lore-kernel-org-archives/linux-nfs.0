Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:51018 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753875Ab1BXRGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Feb 2011 12:06:01 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1Psedc-0005vj-6y
	for linux-nfs@vger.kernel.org; Thu, 24 Feb 2011 18:06:00 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
References: <87wrl6ix2i.fsf@tac.ki.iif.hu> <87mxlpw4cv.fsf@tac.ki.iif.hu>
	<20110222011144.GA18424@fieldses.org> <878vx8huet.fsf@tac.ki.iif.hu>
	<20110223195250.GB13399@fieldses.org>
Date: Thu, 24 Feb 2011 18:06:00 +0100
In-Reply-To: <20110223195250.GB13399@fieldses.org> (J. Bruce Fields's message
	of "Wed, 23 Feb 2011 14:52:51 -0500")
Message-ID: <87r5ax8irr.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Tue, Feb 22, 2011 at 06:05:14PM +0100, Ferenc Wagner wrote:
>
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>
>>> 	- In the NFSv4.1 case there is a "reclaim complete" rpc that
>>> 	  clients are required to send.  Currently we don't take
>>> 	  advantage of that to end the grace period early, but we
>>> 	  should.  That's no help for 4.0 clients.
>> 
>> /proc/fs/nfsd/versions shows +4.1 on the server, does this mean that
>> nfs4 type Linux client mounts should issue "reclaim complete"?
>
> It means that a 4.1 is supported, so a client *could* use 4.1 if it
> asked to.  And if it did use 4.1, yes, it would be required to issue
> reclaim complete.  Current linux clients do not use 4.1 unless you
> explicitly ask for it on the mount commandline.

I can't find any mention of 4.1 in man nfs (nfs-common version 1.2.2),
is there an undocumented nfsvers=4.1 mount option or some other means?

> (Aside: the server really shouldn't have +4.1 by default, as the 4.1
> server is not done.  We should fix that; which distro are you using?)

Debian squeeze.  If it's switchable, then it's possible I switched it
on, I can't remember.  However, 4.1 client support is disabled in the
stock kernel config, and 4.1 server support isn't even mentioned:

$ fgrep NFS /boot/config-2.6.32-5-686 
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_NFS_FSCACHE=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_NCPFS_NFS_NS=y

>> Does the Linux nfs server implementation use the lease time of the
>> previous server instance as grace period on startup, or does it
>> simply take whatever it finds in /proc/fs/nfsd/nfsv4leasetime?
>
> The latest server has separately tunable "nfsv4gracetime" and
> "nfsv4leasetime", and if you want to be careful, you should:
>
> 	- stop the server
> 	- set nfsv4gracetime to the *previous* lease time
> 	- set nfsv4leasetime to the *new* lease time
> 	- start the server
>
> That gives you the new (lower) lease time while still giving a
> sufficiently long grace period for clients who only knew about the old
> time to recover.  After doing that once, on future restarts you can use
> the shorter time for both.

Yes, this is exactly where I was going to (and what's recommended in the
RFC).  Good to hear it's already implemented!

> Probably we should write utilites which do this right for you....

No worries, I won't be changing the lease time that frequently. :)
-- 
Thanks a lot,
Feri.
