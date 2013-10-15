Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37573 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759501Ab3JOPtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 11:49:19 -0400
Date: Tue, 15 Oct 2013 11:49:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wangminlan <wangminlan@huawei.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131015154918.GA6117@fieldses.org>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
 <20131014174540.GA27747@fieldses.org>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looking at the mountd code....

Looks like utils/mountd/cache.c makes no special effort to prioritize
exports except in the v4root and crossmnt cases, neither an issue in
your case.

So yes it depends on ordering. From man exports:

	 If a client matches more than one of the specifications above,
	 then the first match from the above list order takes precedence
	 - regardless  of the  order they appear on the export line.
	 However, if a client matches more than one of the same type of
	 specification (e.g.  two  netgroups), then  the  first  match
	 from  the order they appear on the export line takes
	 precedence.

The order given is: single host, IP networks, wildcards, negroups,
anonymous.

So the single host exports should have taken precedence.

The code here does look like it corectly implements the above ordering.

What version of nfs-utils are you using?

--b.

On Tue, Oct 15, 2013 at 06:39:59AM +0000, Wangminlan wrote:
> On Mon, Oct 14, 2013 at 16:46 +0000, Bruce Fields wrote:
> > On Mon, Oct 14, 2013 at 02:16:58AM +0000, Wangminlan wrote:
> > > 　　Hi,
> > > 　　         I’ve got a problem on the nfs exportfs command. I’m not
> > sure if this is the right place to ask this, if not, can you please tell me where?
> > >
> > > 　　         Here’s what I need:
> > > 　　1. I have a folder named /mnt/fs1 to be exported.
> > > 　　2. All the host in subnetwork 192.168.0.0/16 should be able access this
> > folder, but their root should be squashed.
> > > 　　3. Some specified host in the same subnetwork can gain the root
> > permission on the folder, for example: 192.168.0.21, 192.168.0.22.
> > >
> > > 　　I’ve got a SLES11SP1 box as the nfs server, the nfs clients are SLES11SP1,
> > too, and the protocol used between clients and server are NFSv3.
> > > 　　Here are the commands I used to do the export:
> > > 　　#exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1
> > > 　　#exportfs –o rw,no_root_squash 192.168.0.21:/mnt/fs1
> > > 　　#exportfs –o rw,no_root_squash 192.168.0.22:/mnt/fs1
> > > 　　After this, everything works as expected.
> After this, the contents of /proc/net/rpc/auth.unix.ip/content and /proc/net/rpc/nfsd.export/content are:
> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content 
> 	#class IP domain
> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
> 	nfsd 0.0.0.0 -test-client-
> 	# nfsd 100.43.189.1 -no-domain-
> 
> 	NV200_01:/proc/net/rpc # cat nfsd.export/content 
> 	#path domain(flags)
> 	/mnt/fs1	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=0,anonuid=4294967295,anongid=4294967295)
> 	/mnt/fs1	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree_check,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> 	# /mnt/fs1	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree_check,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> Besides, the content of /var/lib/nfs/etab is:
> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab 
> 	/mnt/fs1	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 	/mnt/fs1	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 	/mnt/fs1	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> > >
> > > 　　But, after the following operations:
> > > 　　#exportfs –u 192.168.0.0/16:/mnt/fs1              /* Delete this
> > export */
> > > 　　# exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1          /*
> > And add it again */
> > > 　　Hosts on 192.168.0.21 and 192.168.0.22 doesn’t get root permission
> > any more. when I tried to write a file, it complains about “Permission denied”.
> > >
> > > 　　So, does the order of exportfs command has something to do the final
> > result? Or am I doing something wrong?
> After this, the contents of /proc/net/rpc/auth.unix.ip/content and /proc/net/rpc/nfsd.export/content are:
> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content 
> 	#class IP domain
> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
> 	nfsd 0.0.0.0 -test-client-
> 	# nfsd 100.43.189.1 -no-domain-
> 
> 	NV200_01:/proc/net/rpc # cat nfsd
> 	nfsd         nfsd.export/ nfsd.fh/     
> 	NV200_01:/proc/net/rpc # cat nfsd
> 	nfsd         nfsd.export/ nfsd.fh/     
> 	NV200_01:/proc/net/rpc # cat nfsd.export/content 
> 	#path domain(flags)
> 	/mnt/fs1	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=0,anonuid=4294967295,anongid=4294967295)
> 	/mnt/fs1	192.168.0.0/16,192.168.0.21(rw,root_squash,sync,wdelay,no_subtree_check,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
> And the content of /var/lib/nfs/etab is:
> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab 
> 	/mnt/fs1	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 	/mnt/fs1	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 	/mnt/fs1	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> > 
> > That sounds like a bug.  The contents of
> > /proc/net/rpc/auth.unix.ip/content and /proc/net/rpc/nfsd.export/content
> > after getting the above "permission denied" might be interesting.
