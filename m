Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33950 "EHLO
	mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbcGWUvC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jul 2016 16:51:02 -0400
Received: by mail-qt0-f178.google.com with SMTP id u25so79073002qtb.1
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jul 2016 13:51:01 -0700 (PDT)
Message-ID: <1469307057.2514.6.camel@redhat.com>
Subject: Re: EACCES race when opening just-created file
From: Jeff Layton <jlayton@redhat.com>
To: Noah Misch <noah@leadboat.com>, linux-nfs@vger.kernel.org
Date: Sat, 23 Jul 2016 16:50:57 -0400
In-Reply-To: <20160723201238.GA2134756@tornado.leadboat.com>
References: <20160723201238.GA2134756@tornado.leadboat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-07-23 at 16:12 -0400, Noah Misch wrote:
> With the Linux kernel as both NFS client and server, I'm seeing a race
> condition where open() can return EACCES for a just-created file.  Is this
> expected behavior?  POSIX implicitly allows it, but I failed to locate any
> discussion of it.  I have attached a test program; here, it witnesses the race
> for roughly a dozen of the 4096 files it creates (different files each time).
> One router separates client from server, with overall ping times as follows:
> 
> 100 packets transmitted, 100 received, 0% packet loss, time 99039ms
> rtt min/avg/max/mdev = 0.173/0.259/4.447/0.422 ms
> 
> This server has three similar clients, each of which witnesses the race.  I
> did not reproduce this in a different NFS setup where client and server were
> virtual machines on the same box.  Those are the only two environments I have
> tested so far.
> 
> -- Server Details
> > [nm@gcc45 0:0 00:36:42 ~]$ uname -a
> Linux gcc45 3.16.0-4-686-pae #1 SMP Debian 3.16.7-ckt11-1+deb8u3 (2015-08-04) i686 GNU/Linux
> > [nm@gcc45 0:0 00:36:37 ~]$ cat /proc/fs/nfs/exports
> # Version 1.1
> # Path Client(Flags) # IPs
> /home   gcc24.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)
> /home   gcc23.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)
> /home   gcc22.tetaneutral.net(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=6797c43c:b0f64b64:bfca4840:f15789eb,sec=1)
> 
> -- Client Details
> > [nm@erpro8-fsf3 0:1 00:37:28 nfs]$ uname -a
> Linux erpro8-fsf3 4.1.4 #1 SMP PREEMPT Mon Aug 3 14:22:54 PDT 2015 mips64 GNU/Linux
> > [nm@erpro8-fsf3 0:1 00:37:49 nfs]$ mount|grep nfs
> gcc45.tetaneutral.net:/home on /home type nfs4 (rw,relatime,vers=4.0,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp6,port=0,timeo=600,retrans=2,sec=sys,clientaddr=2a03:7220:8083:9d00::1,local_lock=none,addr=2a03:7220:8081:8100::1)
> 
> Thanks,
> nm

This is due to a limitation of NFSv3 and NFSv4.0. When you do an
exclusive create, the atime and mtime get set to a particular set of
values (the verifier), and the client is expected to override those
values with a follow-on SETATTR call once it gets those values back.
This is to prevent problems during certain server reboot scenarios. 

The NFS server also sets the mode to 0000 during this time (since the
client can't even set the mode during the operation).

NFSv4.1 is less subject to this problem. You may want to try using that
and see if it's any better.
 
-- 
Jeff Layton <jlayton@redhat.com>
