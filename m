From: Laszlo Monda <monda.laszlo@stud.u-szeged.hu>
Subject: Emptiness under mount points
Date: Mon, 7 Jul 2003 13:16:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030707111645.GC460@crashbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gprs30.vodafone.hu ([80.244.97.80] helo=crashbox)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ZTyi-00060L-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Jul 2003 04:16:18 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I've exported the root directory of one of my boxes.
My problem is that I can't see the anything under the mount points 
except the root partition via NFS.

I know I could export every single mount point separately, but I'd
like to export all the filesystem as a whole in a single line in `exports'.
I've read the NFS Howto and searched on the web but I haven't found
any solutions.

Is it a missing feature or is there any working solution?

Thanks in advance,
    Laci

ps.: Please CC me, I'm not on the list.

Please sign http://noepatents.org against software patents in Europe!


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
