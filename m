From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: the right way to stop NFS
Date: Thu, 19 Jul 2007 17:32:38 +0200
Message-ID: <469F8416.5010309@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBXzh-0007Ts-2x
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 08:32:45 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBXzj-0001us-3U
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 08:32:48 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

In the readme file, there is the detailed startup order for the NFS 
server and client subsystem, which is very useful especially for 
maintainers. But there isn't any description for stopping NFS services. 
On the client, the stop order is almost obvious : unmount nfs 
filesystems, kill statd, kill idmapd and gssd and you are done. But what 
is the right stop order for a server ?
We have :
- svcgssd
- idmapd
- rpc.statd
- nfsd kernel daemons
- mountd

I don't know if we have to stop nfsd first (rpc.nfsd 0) , or maybe 
rpc.mountd ? or even unexport fs first ?

Is there any NFS guru to point this out ?

Thanks,

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
