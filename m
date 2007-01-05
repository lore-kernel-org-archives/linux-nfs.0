From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: trying to unload nfsd
Date: Fri, 05 Jan 2007 13:17:46 +0100
Message-ID: <1167999466.6050.36.camel@lade.trondhjem.org>
References: <1167941208.18576.28.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2o1M-0001vv-JH
	for nfs@lists.sourceforge.net; Fri, 05 Jan 2007 04:18:04 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1++eyxwSC9Vr5ntXMlGTGQMdLxMRYXIpSY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2o1M-0004Pg-Ni
	for nfs@lists.sourceforge.net; Fri, 05 Jan 2007 04:18:06 -0800
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
In-Reply-To: <1167941208.18576.28.camel@pc.ilinx>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-01-04 at 15:06 -0500, Brian J. Murrell wrote:
> I have umounted all of my nfs filesystems and stopped the nfs services.
> I still can't unload the nfsd module:
> 
> $ sudo /sbin/lsmod | grep nfsd
> nfsd                  277152  4 
> exportfs                7680  1 nfsd
> lockd                  77616  1 nfsd
> nfs_acl                 5120  1 nfsd
> sunrpc                174840  7 nfsd,lockd,nfs_acl
> 
> The only thing I can see that could be pinning it still is:
> 
> $ grep nfs /proc/mounts
> sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0
> 
> But I can't seem to umount that:
> 
> $ sudo umount /var/lib/nfs/rpc_pipefs
> umount: /var/lib/nfs/rpc_pipefs: device is busy
> umount: /var/lib/nfs/rpc_pipefs: device is busy
> 
> What could be pinning that fs/mount-point?

Nothing in the sunrpc module depends on anything in nfsd as you can see
from the above lsmod output.

I'd rather expect that you've forgotten to kill off rpc.mountd,
rpc.idmapd and/or rpc.svcgssd.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
