From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: Umount ZIP or CDROM
Date: Fri, 4 Jul 2003 12:11:01 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0307041208090.19686-100000@atx.fast.net>
References: <3F059CB1.7040201@free.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta2.adelphia.net ([64.8.50.178])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19YT9j-0004bH-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Jul 2003 09:11:27 -0700
To: Gaston <menfinquoi@free.fr>
In-Reply-To: <3F059CB1.7040201@free.fr>
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

On Fri, 4 Jul 2003, Gaston wrote:

> Hello,
> 
> How come that I cannot umount and eject a CDROM or ZIP disc when it has 
> been mounted in an NFS (DOS) machine and unmounted.
> 
> The drive is reported as busy.
> 
> I have to stop nfs, umount and eject the disc, then start nfs again.

If you export the CDROM/ZIP, the server regards it as busy regardless of 
whether any clients are using it (remember, NFS is stateless).  It should 
be sufficient to do 'exportfs -u /mnt/cdrom' (use the appropriate path on 
the server).  You should not need to stop nfs.

Steve




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
