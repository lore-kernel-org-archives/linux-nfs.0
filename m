From: James Pearson <james-p@moving-picture.com>
Subject: Re: Odd NFS hung mounts - stale mounts?
Date: Mon, 12 May 2003 17:59:29 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EBFD2F1.BDA127E7@moving-picture.com>
References: <5CA6F03EF05E0046AC5594562398B916A3292E@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
 	"Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>,
 	"Rivera, Angel R" <Angel.R.Rivera@conocophillips.com>,
 	"Wardrop, Mark A." <Mark.A.Wardrop@conocophillips.com>,
 	"Glover, D W" <Dave.Glover@conocophillips.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19FGep-0000hD-00
	for <nfs@lists.sourceforge.net>; Mon, 12 May 2003 10:00:11 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I recently sent a reply to another posting about a similar subject -
see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=105232522611536&w=2

My understanding is that it is not important that the server's
rpc.mountd receives an umount request or not, more importantly, the
server needs to know about existing client mounts when it reboots -
which can get 'removed' in certain circumstances.

James Pearson

"Heflin, Roger A." wrote:
> 
> Basic problem:
> stale nfs file handles.
> 
> Conclusion:
> 
> It looks like when the automounter umounts and if the server does not register
> a "rpc.mountd: authenticated unmount request from" we get into this situation,
> at least on a unused file systems.  I am not exactly sure what is happening
> on the used filesystems.  This is on a high traffic setup with lots of mounts
> and umounts and many many nodes, so given the high volume of mount/umounts
> I would expect some requests to be dropped.
> 
> It looks like when a umount is being done and the server is down or does not
> confirm the umount that the client does not retry the umount and this
> situation occurs, the situation is explained below.
> 
> Does the above seem plausable?
> 
> More information:
> 
> Basic information, client is 2.4.21pre4 NFSALL (and 2.4.19 NFSALL), nfsutils
> 1.0.1-1.
> 
> When doing a df command we get this message in the messages file:
> 
> nfs_statfs: statfs error = 116
> 
> And the df looks like:
> 
> hostname:/usr/applinux    0    1    0   0% /tmpmnt/usr/applinux
> 
> Doing a umount /tmpmnt/usr/applinux fixes the problem (automounter remounts
> it correctly).  I have had the problem happen with both automounter and fstab
> mounted file systems, and I have had it happen with a Solaris 8 machine as
> the server, so that argues to me that this is a client problem and not a
> server problem. I have had it happen on  both 2.4.19 NFSALL and 2.4.21pre4
> NFSALL clients.
> 
> The problem seems to happen without the server or obvious network issues going
> on, though the problem also happens if the server reboots.   The server in
> this case would be 2.4.19 NFSALL, and the mount entry is:
> 
> hostname:/usr/applinux /tmpmnt/usr/applinux nfs rw,v3,
> rsize=8192,wsize=8192,hard,intr,udp,lock,addr=hostname 0 0
> 
> It seems to happen quite a lot if the server reboots (a few out of a lot
> of nodes have the issue), with a umount being required to fix it.  It does
> not happen on all nodes (that we can tell, but it may happen on all nodes
> that try to umount the down filesystem), just on some of the nodes.
> It also will happen with the  client and server both up and ok without any
> warning and without the server  rebooting or having anything funny done on it,
> and it will only affect some  (1 usually) node.  I have had it do this while
> the filesystems is being actively used (process have the fs open), in this case
> the processes have to be killed and  then I umount the filesystems.
> 
> It looks like a client problem of some sort, the network should be relatively
> clean.
> 
>                                                         Roger
> 
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux enterprise solutions
> www.enterpriselinuxforum.com
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
