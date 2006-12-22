From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: Kernel BUG
Date: Fri, 22 Dec 2006 14:42:00 +0100
Message-ID: <1166794920.32117.42.camel@twins>
References: <458BC8AE.2030507@edsons.demon.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	nfs <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gxkh4-0002lk-Vo
	for nfs@lists.sourceforge.net; Fri, 22 Dec 2006 05:44:15 -0800
Received: from amsfep16-int.chello.nl ([62.179.120.11])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gxkh5-00075Z-1U
	for nfs@lists.sourceforge.net; Fri, 22 Dec 2006 05:44:16 -0800
To: Rudy Zijlstra <rudy@edsons.demon.nl>
In-Reply-To: <458BC8AE.2030507@edsons.demon.nl>
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

On Fri, 2006-12-22 at 12:59 +0100, Rudy Zijlstra wrote:
> Hi,
> 
> I have a system where whenever i trigger a ongoing consistent NFS load i 
> get the following kernel BUG:
> 
> ----------
> kernel BUG at mm/truncate.c:311!

Lotsa changes there:
try these:
 http://client.linux-nfs.org/Linux-2.6.x/2.6.19/linux-2.6.19-NFS_ALL.dif

And:
  http://lkml.org/lkml/2006/12/19/279




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
