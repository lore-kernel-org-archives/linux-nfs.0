From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: 2.4.19, Tyan Tiger, Dual Athlon, diskless nodes, rootnfs
 and fsck.ext2 problems
Date: Mon, 7 Oct 2002 11:52:19 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210071149530.8881-100000@kenzo.iwr.uni-heidelberg.de>
References: <Pine.GSO.4.10.10210052237370.2804-100000@condorito.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yUYq-0002ep-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 02:52:25 -0700
To: Nicolas Beaulieu <gulliver@condorito.org>
In-Reply-To: <Pine.GSO.4.10.10210052237370.2804-100000@condorito.org>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Sat, 5 Oct 2002, Nicolas Beaulieu wrote:

> ******************
> 
> Checking root filesystem
> 
> fsck.ext2: Is a directory while trying to open / 
> /:

Could you try adding to /etc/fstab on the node something like:

192.168.0.1:/client/192.168.0.x 	/	nfs	noauto	0 0

The "noauto" part is important to prevent re-mounting by the start-up 
scripts.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
