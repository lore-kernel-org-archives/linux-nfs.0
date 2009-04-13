Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.pronto.com ([66.235.125.216]:56447 "EHLO mail.pronto.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbZDMQsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2009 12:48:04 -0400
Date: Mon, 13 Apr 2009 10:47:59 -0600
From: Daniel Stickney <dstickney@pronto.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Unexplained NFS mount hangs
Message-ID: <20090413104759.525161b2@dstickney2>
In-Reply-To: <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
References: <20090413092406.304d04fb@dstickney2>
	<C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 13 Apr 2009 12:12:47 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 13, 2009, at 11:24 AM, Daniel Stickney wrote:
> > Hi all,
> >
> > I am investigating some NFS mount hangs that we have started to see  
> > over the past month on some of our servers. The behavior is that the  
> > client mount hangs and needs to be manually unmounted (forcefully  
> > with 'umount -f') and remounted to make it work. There are about 85  
> > clients mounting a partition over NFS. About 50 of the clients are  
> > running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of  
> > these 50 has ever had this mount hang. The other 35 are CentOS 5.2  
> > with kernel 2.6.27 which was compiled from source. The mount hangs  
> > are inconsistent and so far I don't know how to trigger them on  
> > demand. The timing of the hangs as noted by the timestamp in /var/ 
> > log/messages varies. Not all of the 35 CentOS clients have their  
> > mounts hang at the same time, and the NFS server continues operating  
> > apparently normally for all other clients. Normally maybe 5 clients  
> > have a mount hang per week, on different days, mostly different  
> > times. Now and then we might see a cluster of a few clien
> > ts have their mounts hang at the same exact time, but this is not  
> > consistent. In /var/log/messages we see
> >
> > Apr 12 02:04:12 worker120 kernel: nfs: server broker101 not  
> > responding, still trying
> 
> Are these NFS/UDP or NFS/TCP mounts?
> 
> If you use a different kernel (say, 2.6.26) on the CentOS systems, do  
> the hangs go away?

Hi Chuck,

Thanks for your reply. The mounts are NFSv3 over TCP. We have not tried a different kernel (because of the number of servers to be upgraded), but that is next on to ToDo list. Wanted to explore the possibility that some other change might resolve the issue, but I am getting close to launching the kernel upgrades. (The prepackaged RHEL/CentOS 2.6.18* kernels have other NFS client problems with attribute caching which really mess things up, so that is why we have had to compile from source)

To add a little more info, in a post on April 10th titled "NFSv3 Client Timeout on 2.6.27" Bryan mentioned that his client socket was in state FIN_WAIT2, and server in CLOSE_WAIT, which is exactly what I am seeing here. 

tcp        0      0 worker120.cluster:944       broker101.cluster:nfs       FIN_WAIT2   

This is especially interesting because the original nfs "server not responding" message was about 32 hours ago. On this same client, all other NFS mounts to other servers are showing state "established". 

-Daniel

> 
> > One very interesting aspect of this behavior is that the load value  
> > on the client with the hung mount immediately spikes to (16.00)+ 
> > (normal load value). We have also seen client load spikes to (30.00)+ 
> > (normal load value). These discrete load value increases might be a  
> > good hint.
> >
> > Running 'df' prints some output and then hangs when it reaches the  
> > hung mount point. 'mount -v' shows the mount point like normal. When  
> > an NFS server is rebooted, we are used to seeing the client log a  
> > "nfs: server ___________ not responding, still trying", then a "nfs:  
> > server __________ OK" message when it comes back online. With this  
> > issue there is never an "OK" message even though the NFS server is  
> > still functioning for all other NFS clients. On a client which has a  
> > hung NFS mount, running 'rpcinfo -p' and 'showmount -e' against the  
> > NFS server shows that RPC and NFS appear to be functioning between  
> > client and server even during the issue.
> >
> >
> > # rpcinfo -p broker101
> >   program vers proto   port
> >    100000    2   tcp    111  portmapper
> >    100000    2   udp    111  portmapper
> >    100021    1   udp  32779  nlockmgr
> >    100021    3   udp  32779  nlockmgr
> >    100021    4   udp  32779  nlockmgr
> >    100021    1   tcp  60389  nlockmgr
> >    100021    3   tcp  60389  nlockmgr
> >    100021    4   tcp  60389  nlockmgr
> >    100011    1   udp    960  rquotad
> >    100011    2   udp    960  rquotad
> >    100011    1   tcp    963  rquotad
> >    100011    2   tcp    963  rquotad
> >    100003    2   udp   2049  nfs
> >    100003    3   udp   2049  nfs
> >    100003    4   udp   2049  nfs
> >    100003    2   tcp   2049  nfs
> >    100003    3   tcp   2049  nfs
> >    100003    4   tcp   2049  nfs
> >    100005    1   udp    995  mountd
> >    100005    1   tcp    998  mountd
> >    100005    2   udp    995  mountd
> >    100005    2   tcp    998  mountd
> >    100005    3   udp    995  mountd
> >    100005    3   tcp    998  mountd
> >
> >
> > # showmount -e broker101
> > Export list for broker101:
> > /mnt/sdc1 *
> > /mnt/sdb1 *
> >
> >
> > It is confusing that the NFS client doesn't recover automatically.  
> > So whatever the issue is evidently is blocking the kernel from  
> > seeing that the NFS server is live and functioning after the issue  
> > is triggered.
> >
> > I'm running low on ideas of how to resolve this. One idea I have is  
> > to modify some NFS client timeout values, but I don't have a  
> > specific reason to think this will resolve the problem. Right now  
> > the values are:
> >
> > # sysctl -a | grep -i nfs
> > fs.nfs.nlm_grace_period = 0
> > fs.nfs.nlm_timeout = 10
> > fs.nfs.nlm_udpport = 0
> > fs.nfs.nlm_tcpport = 0
> > fs.nfs.nsm_use_hostnames = 0
> > fs.nfs.nsm_local_state = 0
> > fs.nfs.nfs_callback_tcpport = 0
> > fs.nfs.idmap_cache_timeout = 600
> > fs.nfs.nfs_mountpoint_timeout = 500
> > fs.nfs.nfs_congestion_kb = 65152
> > sunrpc.nfs_debug = 0
> > sunrpc.nfsd_debug = 0
> >
> >
> > I've turned on nfs debugging but there was a tremendous amount of  
> > output because of the NFS clients activity on several different (and  
> > working) NFS mount points. I can capture and supply this output  
> > again if it would be helpful. Has anyone seen this behavior before,  
> > and does anyone have any suggestions for how this might be resolved?
> >
> > Thanks for your time,
> >
> > Daniel Stickney
> > Operations Manager - Systems and Network Engineer
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



Daniel Stickney
Operations Manager - Systems and Network Engineer
