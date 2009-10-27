From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: NFSv4 Kernel-server requires 2x manual restart after reboot?
 Maybe a 	timing problem?
Date: Tue, 27 Oct 2009 10:04:53 +0530
Message-ID: <4AE6786D.9000906@suse.de>
References: <babafd2f0910231007h329e75b7raa7207d0b816a72a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Ben DJ <bendj095124367913213465@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
In-Reply-To: <babafd2f0910231007h329e75b7raa7207d0b816a72a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/23/2009 10:37 PM, Ben DJ wrote:
> I've installed NFSv4 as nfs-kernel-server.  I'm slowly figuring out
> how to get it to configured and working.
> 
> After a system reboot, if I try to mount an export,
> 
> 	mount -t nfs4 192.168.1.2:/test /mnt/test

Shouldn't it be 192.168.1.2:/ (excluding share name in case of NFSv4) or
has it changed?

Are you able to mount successfully if you just use the server name
like below:
	mount -t nfs4 192.168.1.2:/ /mnt/test (in your case)

> it just "sits there", never mounting.

I'm also running a 11.2 RC1 and tried to mount nfs4 the way you
mentioned, but I don't see the hang you're observing:

mount -t nfs4 192.168.100.254:/export  /mnt/nfs/
mount.nfs4: mounting 192.168.100.254:/export failed, reason given by
server:  No such file or directory

Can you try to run mount with '-v' and post the output?

> So I 1st check what's running,
> 
> 	ps ax | egrep -i "idmapd|mountd|statd|nfsd|sm-notify"
> 	 3731 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 	 3732 ?        Ss     0:00 /usr/sbin/rpc.idmapd

I'm not sure why you have two instances of idmapd.. Did you start idmapd
once again?

> 
> After some experiments, I've discovered if I CTRL-C the mount attempt
> and restart the server TWICE,

This is odd.

> 	service nfsserver restart
> 		Shutting down kernel based NFS server: nfsd statd mountd
>                                                 done
> 		Starting kernel based NFS server: idmapdexportfs: Warning: /nfs/test
> does not support NFS export.
> 		 mountd statd nfsd sm-notify
>                                                 done
> 	
> 	service nfsserver restart
> 		Shutting down kernel based NFS server: nfsd statd mountd
>                                                 done
> 		Starting kernel based NFS server: idmapd mountd statd nfsd sm-notify
>                                                 done
> 
> Notice that the 2nd time the "idmapd" appears to be re-started.
> 
> then repeat the mount attempt,
> 
> 	mount -t nfs4 192.168.1.2:/test /mnt/test
> 
> it now works.
> 
> 
> I don't really understand what the 2X nfsserver restart does.  There
> clearly IS an effect. And it looks like it has to do with idmapd.

Have you enabled nfsserver during startup (chkconfig nfsserver on)?

> I can say that
> 
> 	service nfsserver stop
> 	service nfs stop
> 	service quotad stop
> 	service rpcbind stop
> 	umount -a
> 	mount  -a
> 	service rpcbind start
> 	service quotad start
> 	service nfs start
> 	service nfsserver start
> 
> often gives me similar errors,
> 
> 	Warning: /nfs/test does not support NFS export
> 
> that go away if I make sure there's a delay after starting nfs,
> 
> 	service nfs start && sleep 5
> 	service nfsserver start
> 
> Maybe there's some sort of timing problem on startup?
> 
> Any clues?
> 

not much at the moment..

Thanks,


-- 
Suresh Jayaraman
