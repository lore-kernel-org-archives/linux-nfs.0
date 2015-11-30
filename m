Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbbK3XHG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2015 18:07:06 -0500
Date: Mon, 30 Nov 2015 18:07:05 -0500
To: Peter Thurner <p.thurner@blunix.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS Kernel Panics
Message-ID: <20151130230705.GD31564@fieldses.org>
References: <565C7747.1080703@blunix.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <565C7747.1080703@blunix.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2015 at 05:20:23PM +0100, Peter Thurner wrote:
> Hi guys,
> 
> I'm running the following Setup on Ubuntu 14.04 for both Server and Clients:

I don't know what kernel version that translates to.

Ideally this would either get reported to Ubuntu, or reproduced with an
upstream kernel before getting reported here.

> 
> 
> == NFS Server with /etc/exports:
> 
> /var/www/ 172.16.1.254(rw,no_root_squash,sync,no_subtree_check)
> 172.16.1.184(rw,no_root_squash,sync,no_subtree_check)
> 172.16.0.120(rw,no_root_squash,sync,no_subtree_check)
> 172.16.0.193(rw,no_root_squash,sync,no_subtree_check)
> 
> Version: 1:1.2.8-6ubuntu1.2
> 
> 
> == Four NFS Clients with fstab:
> 
> alpha:/var/www        /var/www    nfs4   
> nosharecache,fsc=example_web,noatime,tcp,bg,nosuid,rsize=32768,wsize=32768,soft,proto=tcp   
> 0 0
> 
> On the Clients i'm using cachefilesd:
> 
> /var/cache/cachefilesd/loopimage.img       
> /var/cache/cachefilesd/srv    ext4   
> loop,rw,relatime,errors=continue,user_xattr,acl,barrier=1,data=ordered    0
> 0
> 
> root@web1:~# cat /etc/cachefilesd.conf
> dir /var/cache/cachefilesd/srv
> tag nfs_filesystem_cache
> brun 20%
> frun 10%
> bcull 10%
> fcull 7%
> bstop 5%
> fstop 3%
> 
> 
> == Problem
> 
> Both server and clients experience random kernel Panics. Of the five
> machines, around one dies per die.

per day?

> They all run on Amazon AWS as
> m4.large instances. When I set
> 
> rpcdebug -m nfsd -s all
> rpcdebug -m rpc -s all
> 
> The messages before the crash (this time on the NFS server) are:
> 
> ```
> Nov 30 13:49:54 nfs-master kernel: [38232.649545] nfsd_dispatch: vers 4
> proc 1
> Nov 30 13:49:54 nfs-master kernel: [38232.649547] nfsv4 compound op
> #1/3: 22 (OP_PUTFH)
> Nov 30 13:49:54 nfs-master kernel: [38232.649548] nfsd: fh_verify(32:
> 81060001 0c7791ab ab46dd87 663ae28a 6877949f 2802898e)
> Nov 30 13:49:54 nfs-master kernel: [38232.649552] nfsv4 compound op
> ffff8802026c8080 opcnt 3 #1: 22: status 0
> Nov 30 13:49:54 nfs-master kernel: [38232.649553] nfsv4 compound op
> #2/3: 4 (OP_CLOSE)
> Nov 30 13:49:54 nfs-master kernel: [38232.649554] NFSD: nfsd4_close on
> file objectLinksShadow.png
> Nov 30 13:49:54 nfs-master kernel: [38232.649556] NFSD:
> nfs4_preprocess_seqid_op: seqid=818421 stateid =
> (565bb0a0/00000001/00083f05/00000001)
> Nov 30 13:49:54 nfs-master kernel: [38232.649557] renewing client
> (clientid 565bb0a0/00000001)
> Nov 30 13:49:54 nfs-master kernel: [38232.649558] NFSD:
> move_to_close_lru nfs4_openowner ffff8800373b8000
> Nov 30 13:49:54 nfs-master kernel: [38232.649559] nfsv4 compound op
> ffff8802026c8080 opcnt 3 #2: 4: status 0
> Nov 30 13:49:54 nfs-master kernel: [38232.649560] nfsv4 compound op
> #3/3: 9 (OP_GETATTR)
> Nov 30 13:49:54 nfs-master kernel: [38232.649562] nfsd: fh_verify(32:
> 81060001 0c7791ab ab46dd87 663ae28a 6877949f 2802898e)
> Nov 30 13:49:54 nfs-master kernel: [38232.649564] nfsv4 compound op
> ffff8802026c8080 opcnt 3 #3: 9: status 0
> Nov 30 13:49:54 nfs-master kernel: [38232.649565] nfsv4 compound returned 0
> Nov 30 13:49:54 nfs-master kernel: [38232.649570] svc: socket
> ffff8800e929d000 sendto([ffff8801e07ae000 136... ], 136) = 136 (addr
> 172.16.0.120, port=958)
> Nov 30 13:49:54 nfs-master kernel: [38232.649571] svc: server
> ffff880202142000 waiting for data (to = 900000)

This all looks pretty normal to me.

> Nov 30 13:49:54 nfs-master rsyslogd: [origin software="rsyslogd"
> swVersion="7.4.4" x-pid="939" x-info="http://www.rsyslog.com"] exiting
> on signal 15.

That's SIGTERM.  No idea if that means anything.

Sorry, I don't see anything much to go on here.  Is there a console that
might have anything more?  I'm not very familiar with AWS.

--b.

> Server is rebooting here
> 
> Nov 30 13:50:34 nfs-master rsyslogd: [origin software="rsyslogd"
> swVersion="7.4.4" x-pid="951" x-info="http://www.rsyslog.com"] start
> Nov 30 13:50:34 nfs-master rsyslogd-2307: warning: ~ action is
> deprecated, consider using the 'stop' statement instead [try
> http://www.rsyslog.com/e/2307 ]
> Nov 30 13:50:34 nfs-master rsyslogd: rsyslogd's groupid changed to 104
> Nov 30 13:50:34 nfs-master rsyslogd: rsyslogd's userid changed to 101
> Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
> subsys cpuset
> Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
> subsys cpu
> Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
> subsys cpuacct
> 
> ```
> 
> 
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
