Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37810 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752162AbeCEVuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 16:50:24 -0500
Date: Mon, 5 Mar 2018 16:50:23 -0500
To: Sergio Traldi <sergio.traldi@pd.infn.it>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS sync and async mode
Message-ID: <20180305215023.GB29226@fieldses.org>
References: <b4b5c9d2-409f-fbd3-4b87-7b4ae41427cf@pd.infn.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <b4b5c9d2-409f-fbd3-4b87-7b4ae41427cf@pd.infn.it>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should be on a FAQ or something.  Anyway, because I've been
thinking about it lately:

On an NFS filesystem, creation of a new file is a synchronous operation:
the client doesn't return from open()/creat() until it's gotten a
response from the server, and the server isn't allowed to respond until
it knows that the file creation has actually reached disk--so it'll
generally be waiting for at least a disk seek or two.

Also when it finishes writing a file and closes it, the close() has to
wait again for the new data to hit disk.

That's probably what dominates the runtime in your case.  Take the
number of files in that tarball and divide into the total runtime, and
the answer will probably be about the time it takes to create one file
and commit the write data on close.

As you know, exporting with async is not recommended--it tells the
server to violate the protocol and lie to the client, telling it that
the client that stuff has reached disk when it hasn't really.  This
works fine until you have a power outage and a bunch of files that the
file has every right to believe were actually sync'd to disk suddenly
vanish....

Other possible solutions/workarounds:

	- use storage that can commit data to stable storage very
	  quickly: this is what most "real" NFS servers do, generally I
	  think by including some kind of battery-backed RAM to use as
	  write cache.  I don't know if this is something your HP
	  controllers should be able to do.

	  The cheapo version of this approach that I use for my home
	  server is an SSD with capacitors sufficient to destage the
	  write cache on shutdown.  SSDs marketed as "enterprise" often
	  do this--look for something like "power loss protection" in
	  the specs.  Since I was too cheap to put all my data on SSDs,
	  I use an ext4 filesystem on a couple big conventional drives,
	  mounted with "data=journal" and an external journal on an SSD.

	- write a parallel version of tar.  Tar would go a lot faster if
	  it wasn't forced to wait for one file creation before starting
	  the next one.

	- implement NFS write delegations: we've got this on the client,
	  I'm working on the server.  It can't help with the latency of
	  the original file create, but it should free the client from
	  waiting for the close.  But I don't know if/how much it will
	  help in practice yet.

	- specify/implement NFS directory write delegations: there's not
	  really any reason the client *couldn't* create files locally
	  and later commit them to the server, somebody just needs to
	  write the RFC's and the code.

	  I seem to remember Trond also had a simpler proposal just to
	  allow the server to return from a file-creating OPEN without
	  waiting for disk if it returned a write delegation, but I
	  can't find that proposal right now....

--b.

On Mon, Mar 05, 2018 at 10:53:21AM +0100, Sergio Traldi wrote:
> I have host A  and host B using nfs4 or nfs3.
> In host A I mount a partition or a disk formatted in ext4 or xfs in
> /nfsdisk
> I put this file inside the directory:
> wget --no-check-certificate https://root.cern.ch/download/root_v6.08.06.Linux-centos7-x86_64-gcc4.8.tar.gz
> -O /nfsdisk/root_v6.08.06.Linux-centos7-x86_64-gcc4.8.tar.gz
> 
> In host A I export that partition with this line in /etc/exports
> /nfsdisk
> 192.168.1.1.0/24(rw,sync,no_wdelay,no_root_squash,no_subtree_check)
> OR using async mode:
> /nfsdisk 192.168.1.1.0/24(rw,async,no_root_squash)
> 
> From host B I mount via nfs the disk:
> mount -t nfs <ip-hostA>:/nfsdisk /nfsdisk
> 
> and I obtain something similar to (with mount command):
> 192.168.1.1:/nfstest on /nfstest type nfs4 (rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.2,local_lock=none,addr=192.168.1.1)
> 
> In host B I exec:
> time tar zxvf root_v6.08.06.Linux-centos7-x86_64-gcc4.8.tar.gz
> 
> I try with different hosts bare metal or virtual machine and with
> different controller.
> 1) with bare metal host:
> 1.1) A and B bare metal with CentOS7 with kernel 3.10.0-514.2.2.el7
> with nfs-utils-1.3.0-0.48.el7_4.1.x86_64 and
> rpcbind-0.2.0-42.el7.x86_64
> 
> In host A:
> real    0m45.338s
> user    0m8.334s
> sys    0m5.387s
> 
> In Host B I obtain
>   sync mode:
> real    11m56.146s
> user    0m9.947s
> sys    0m8.346s
>   async mode:
> real    0m46.328s
> user    0m8.709s
> sys    0m5.747s
> 
> 1.2) A and B bare metal with Ubuntu 14.04 jessie with kernel
> 3.13.0-141-generic with nfs-common 1:1.2.8-6ubuntu1.2 - nfs-server
> 1:1.2.8-6ubuntu1.2  - rpcbind 0.2.1-2ubuntu2.2
> 
> In host A:
> real    0m10.667s
> user    0m7.856s
> sys    0m3.190s
> 
> In host B:
>    sync mode:
> real    9m45.146s
> user    0m9.697s
> sys    0m8.037s
>   async mode:
> real    0m14.843s
> user    0m7.916s
> sys    0m3.780s
> 
> 1.3) A and B bare metal with Scientific Linux 6.2 with Kernel
> 2.6.32-220.el6.x86_64 with nfs-utils-1.2.3-15.el6.x86_64 -
> rpcbind-0.2.0-13.el6_9.1.x86_64
> 
> In host A:
> real    0m5.943s
> user    0m5.611s
> sys    0m1.585s
> 
> In host B:
>    sync mode:
> real    8m37.495s
> user    0m5.680s
> sys    0m3.091s
>    async mode:
> real    0m21.121s
> user    0m5.782s
> sys    0m3.089s
> 
> 2) with Virtual Machine Libvirt KVM
> 2.1) A and B virtual with CentOS7 with kernel 3.10.0-514.2.2.el7
> with nfs-utils-1.3.0-0.48.el7_4.1.x86_64 and
> rpcbind-0.2.0-42.el7.x86_64
> 
> In host A:
> real    0m46.126s
> user    0m9.034s
> sys    0m6.187s
> 
> In Host B I obtain
>   sync mode:
> real    12m31.167s
> user    0m9.997s
> sys    0m8.466s
>   async mode:
> real    0m45.388s
> user    0m8.416s
> sys    0m5.587s
> 
> 2.2) A and B virtual with Ubuntu 14.04 jessie with kernel
> 3.13.0-141-generic with nfs-common 1:1.2.8-6ubuntu1.2 - nfs-server
> 1:1.2.8-6ubuntu1.2  - rpcbind 0.2.1-2ubuntu2.2
> In  host A:
> real    0m10.787s
> user    0m7.912s
> sys    0m3.335s
> 
> In Host B I obtain
>   sync mode:
> real    11m54.265s
> user    0m8.264s
> sys    0m6.541s
>    async mode:
> real    0m11.457s
> user    0m7.619s
> sys    0m3.531s
> 
> Just in two other bare metal hosts I have same situation of 1.3 (old
> O.S. and old nfs) and I obtain sync and asyc mode in host B similar
> in about:
> real    0m37.050s
> user    0m9.326s
> sys    0m4.220s
> in that case the host A has a controller RAID bus controller:
> Hewlett-Packard Company Smart Array G6 controllers (rev 01)
> 
> Now my question why is there to much difference from sync and async mode?
> 
> I try to optimize network in A and B, I try to mount with different
> rsize and wsize in B host, I try to change timeo in nfs from B.|
> I try to to increase nfsd threads in host A.
> I try to change disk scheduler ( /sys/block/sda/queue/scheduler noop
> deadline [cfq]) in host A.
> I try to use NFS3.
> 
> I observe some little improvement in some case but the gap from
> async and sync is always very high, except for the bare metal with
> G6 array controller.
> 
> We would like to use nfs with sync for our infrastructure, but we
> can not loose to much performance.
> 
> Is there a way to use sync mode with some specific parameter and
> improve considerably performance?
> 
> Thanks in advance for any hint.
> Cheers
> Sergio
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
