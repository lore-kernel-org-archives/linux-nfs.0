Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:57656 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500Ab1K3KOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 05:14:33 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RVhAS-0006Ld-Sx
	for linux-nfs@vger.kernel.org; Wed, 30 Nov 2011 11:14:32 +0100
Received: from 194.146.132.141 ([194.146.132.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 11:13:32 +0100
Received: from free.lan.c2.718r by 194.146.132.141 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 11:13:32 +0100
To: linux-nfs@vger.kernel.org
From: Pavel <free.lan.c2.718r@gmail.com>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 30 Nov 2011 10:13:21 +0000 (UTC)
Message-ID: <loom.20111130T104304-71@post.gmane.org>
References: <46156F3F.3070606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wendy Cheng <wcheng <at> redhat.com> writes:

> 
> Revised patches based on 2.6.21-rc4 kernel and nfs-utils-1.1.0-rc1 that 
> address issues discussed in:
> https://www.redhat.com/archives/cluster-devel/2006-September/msg00034.html
> 
> Quick How-to:
> 1) Failover server exports filesystem with "fsid" option as:
>     /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
> 2) Failover server dispatch rpc.statd with "-H" option.
> 3) Failover server drops locks based on fsid by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
> 4) Takeover server enters per fsid grace period by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
> 5) Takeover server notifies clients for lock reclaim by:
>     shell> /usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory
> 
> Patch Summary:
> 4-1: implement /proc/fs/nfsd/nlm_unlock
> 4-2: implement /proc/fs/nfsd/nlm_set_igrace
> 4-3: correctly record and pass incoming server ip interface into rpc.statd.
> 4-4: nfs-utils statd changes
> 4-1 includes an existing lockd bug fix as discussed in:
> http://sourceforge.net/mailarchive/forum.php?
thread_name=4603506D.5040807%40redhat.com&forum_name=nfs
> (subject: [NFS] Question about f_count in struct nlm_file)
> 4-4 includes an existing nfs-utils statd bug fix as discussed in:
> http://sourceforge.net/mailarchive/message.php?
msg_name=46142B4F.1030507%40redhat.com
> (subject: Re: [NFS] lockd and statd)
> 
> Misc:
> o No IPV6 support due to testing efforts
> o NFS V3 only - will compare notes with CITI folks (NFS V4 issues)
> o Still need some error-inject tests.
> 

Hi everyone!

I'm building an A/A cluster using NFS v3 and local file systems, and looking for 
efficient ways for failover (for now I have to restart nfs-kernel-server on 
Takeover node to be able to initiate grace period), so the discussed solutions 
are very interesting to me.

Now (4 years after) in current nfs-utils packages (v. 1.2.2-4 and later) I can 
see that the ability to release locks was really implemented and is working well 
(I mean interfaces /proc/fs/nfsd/unlock_ip and /proc/fs/nfsd/unlock_filesystem), 
but how about reacquiring locks on the node, share migrates to? - I've been 
going through various mailing lists and found a lot of discussions on the topic 
(also dated mainly 2007), but don't seem to find any rpc-based mechanism or 
interface like /proc/fs/nfsd/nlm_set_grace to do that, was it ever made?

Thanks!


