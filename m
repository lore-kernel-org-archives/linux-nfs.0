From: Steve Dickson <SteveD@redhat.com>
Subject: Re: trying to unload nfsd
Date: Mon, 08 Jan 2007 10:57:04 -0500
Message-ID: <45A269D0.40909@RedHat.com>
References: <1167941208.18576.28.camel@pc.ilinx>
	<1167999466.6050.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Brian J. Murrell" <brian@interlinx.bc.ca>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3wsX-0006HE-66
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 07:57:41 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3wsX-0004uR-Lw
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 07:57:43 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1167999466.6050.36.camel@lade.trondhjem.org>
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



Trond Myklebust wrote:

> I'd rather expect that you've forgotten to kill off rpc.mountd,
> rpc.idmapd and/or rpc.svcgssd.
Right... here is what I do to unload both nfsd and sunrpc
service nfs stop && service rpcidmapd stop &&
umount /proc/fs/nfsd  && rmmod nfsd
rmmod lockd && rmmod nfs_acl
umount /var/lib/nfs/rpc_pipefs && rmmod sunrpc

(Note: this assumes there are entires in /etc/fstab
for both /proc/fs/nfsd and var/lib/nfs/rpc_pipefs.
It also assumes the Secure NFS gssd daeamon are not
running).

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
