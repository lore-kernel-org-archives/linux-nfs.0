From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 Kernel-server requires 2x manual restart after reboot?
	Maybe a timing problem?
Date: Fri, 23 Oct 2009 13:27:19 -0400
Message-ID: <20091023172719.GB31133@fieldses.org>
References: <babafd2f0910231007h329e75b7raa7207d0b816a72a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ben DJ <bendj095124367913213465@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47190 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbZJWR0F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 13:26:05 -0400
In-Reply-To: <babafd2f0910231007h329e75b7raa7207d0b816a72a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 23, 2009 at 10:07:23AM -0700, Ben DJ wrote:
> I've installed NFSv4 as nfs-kernel-server.

What distro and versions are you using?

> I'm slowly figuring out
> how to get it to configured and working.
> 
> After a system reboot, if I try to mount an export,
> 
> 	mount -t nfs4 192.168.1.2:/test /mnt/test
> 
> it just "sits there", never mounting.
> 
> So I 1st check what's running,
> 
> 	ps ax | egrep -i "idmapd|mountd|statd|nfsd|sm-notify"
> 	 3731 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 	 3732 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 	 3753 ?        Ss     0:00 /usr/sbin/rpc.statd --no-notify
> 	 3758 ?        S<     0:00 [nfsd4]
> 	 3759 ?        S<     0:00 [nfsd]
> 	 3760 ?        S<     0:00 [nfsd]
> 	 3761 ?        S<     0:00 [nfsd]
> 	 3762 ?        S<     0:00 [nfsd]
> 	 3772 ?        Ss     0:00 /usr/sbin/rpc.mountd
> 
> and that looks OK.
> 
> After some experiments, I've discovered if I CTRL-C the mount attempt
> and restart the server TWICE,
> 
> 	service nfsserver restart
> 		Shutting down kernel based NFS server: nfsd statd mountd
>                                                 done
> 		Starting kernel based NFS server: idmapdexportfs: Warning: /nfs/test
> does not support NFS export.

Huh.  What filesystem is at /nfs/test?

--b.

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
> Checking what's running again,
> 
> 	ps ax | egrep -i "idmapd|mountd|statd|nfsd|sm-notify"
> 	
> 	 3731 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 	 3732 ?        Ss     0:00 /usr/sbin/rpc.idmapd
> 	 5213 ?        S<s    0:00 /usr/sbin/rpc.mountd
> 	 5216 ?        S<s    0:00 /usr/sbin/rpc.statd --no-notify
> 	 5221 ?        S<     0:00 [nfsd4]
> 	 5222 ?        S<     0:00 [nfsd]
> 	 5223 ?        S<     0:00 [nfsd]
> 	 5224 ?        S<     0:00 [nfsd]
> 	 5225 ?        S<     0:00 [nfsd]
> 
> It all looks the same as before.  Notice that the rpc.idmapd PIDs are
> the same, even though the "service nfsserver restart" 2nd time around
> looked like it restarted it.
> 
> I don't really understand what the 2X nfsserver restart does.  There
> clearly IS an effect. And it looks like it has to do with idmapd.
> 
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
> BenDJ
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
