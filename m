From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd using up 60% CPU and won't let go
Date: Mon, 29 Sep 2008 13:14:07 -0400
Message-ID: <20080929171407.GA23212@fieldses.org>
References: <48E10657.7020503@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Just Marc <marc-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbYI2ROJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 13:14:09 -0400
In-Reply-To: <48E10657.7020503-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2008 at 12:46:15PM -0400, Just Marc wrote:
> Doing a seemingly innocent operation such as opening a file with vim on  
> a CFS (yes, that old crypto file system)

It's basically just a userspace NFS server, right?

> NFS mount, lockd would wake up  
> and take 60% of my CPU away - probably doing nothing important but  
> certainly keeping the CPU busy, forever.

Could you work around the problem by mounting with -onolock?

> I use kernel 2.6.26 and kernel NFS.   Some detail is available below:
>
> $ grep nfs /proc/mounts
> nfsd /proc/fs/nfsd nfsd rw 0 0localhost:/var/lib/cfs/.cfsfs /var/cfs nfs  

(Missing end-of-line before "localhost"?)

> rw,vers=2,rsize=8192,wsize=8192,namlen=255,hard,intr,proto=udp,timeo=11,retrans=3,sec=sys,addr=127.0.0.1 
> 0 0
> localhost:/var/lib/cfs/.cfsfs/x /var/cfs/x nfs  
> rw,vers=2,rsize=8192,wsize=8192,namlen=255,hard,intr,proto=udp,timeo=11,retrans=3,sec=sys,addr=127.0.0.1 
> 0 0
>
> $ egrep 'NFS|_LOCKD' .config
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> CONFIG_NFSD=y
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V4=y
> CONFIG_ROOT_NFS=y
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
>
> I noticed this a few weeks ago but I don't quite know what causes it but  
> I certainly know how to trigger it.   Stopping CFS and NFS completely  
> doesn't help - as soon as NFS is restarted lockd starts eating CPU again  
> just like before.
>
> I'd appreciate any hints on what I can do to find the root cause of the  
> problem and help get this bug out of the way.

You might try running wireshark on the "lo" interface and seeing whether
there's any NLM traffic from lockd.

Or a sysrq-t trace ("echo t >/proc/sysrq-trigger", then look in the
logs) might show what lockd's doing.

--b.
