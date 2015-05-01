Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52102 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbEAEjm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 00:39:42 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>
	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl>
	<871tpx1gcx.fsf@x220.int.ebiederm.org> <544B7D9F.1070403@xmsnet.nl>
	<87k33ow65k.fsf@x220.int.ebiederm.org> <544C1E40.6070901@xmsnet.nl>
Date: Thu, 30 Apr 2015 23:35:18 -0500
In-Reply-To: <544C1E40.6070901@xmsnet.nl> (Hans de Bruin's message of "Sun, 26
	Oct 2014 00:03:44 +0200")
Message-ID: <87pp6kewzd.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot laptop
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hans de Bruin <jmdebruin@xmsnet.nl> writes:

>> I expect what needs to happen is to confirm that nfs directory entry
>> revalidation is buggy, and at least for the short term re-add the nfs
>> logic that will avoid dropping a dentry if it is a mount point, or
>> path to a mount point, to avoid the nfs bugs.
>>
>
> ok, I will go in waiting mode.

I dropped the ball on this but it looks like someone else hit the
problem and the following two commits fixed this issue:

Can you confirm that things are working again?

commit fa9233699cc1dc236f4cf42245d13e40966938c5
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Mon Feb 23 18:51:32 2015 -0500

    NFS: Don't require a filehandle to refresh the inode in nfs_prime_dcache()
    
    If the server does not return a valid set of attributes that we can
    use to either create a file or refresh the inode, then there is no
    value in calling nfs_prime_dcache().
    
    However if we're just refreshing the inode using the attributes that
    the server returned, then it shouldn't matter whether or not we have
    a filehandle, as long as we check the fsid+fileid combination.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

commit 6c441c254eea2354d686be7f5544bcd79fb6a61f
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Sun Feb 22 16:35:36 2015 -0500

    NFS: Don't invalidate a submounted dentry in nfs_prime_dcache()
    
    If we're traversing a directory which contains a submounted filesystem,
    or one that has a referral, the NFS server that is processing the READDIR
    request will often return information for the underlying (mounted-on)
    directory. It may, or may not, also return filehandle information.
    
    If this happens, and the lookup in nfs_prime_dcache() returns the
    dentry for the submounted directory, the filehandle comparison will
    fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
    ("vfs: Lazily remove mounts on unlinked files and directories."), this
    means the entire subtree is unmounted.
    
    The following minimal patch addresses this problem by punting on
    the invalidation if there is a submount.
    
    Kudos to Neil Brown <neilb@suse.de> for having tracked down this
    issue (see link).
    
    Reported-by: Nix <nix@esperi.org.uk>
    Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
    Cc: stable@vger.kernel.org # 3.18+
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

