From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: NFS as a Cluster File System.
Date: Fri, 10 Jan 2003 06:51:08 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D551DF@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18X0VA-0007ln-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 06:51:16 -0800
To: "'Brian Tinsley'" <btinsley@emageon.com>,
   Lorn Kay
	 <lorn_kay@hotmail.com>
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

> -----Original Message-----
> From: Brian Tinsley [mailto:btinsley@emageon.com] 
> Sent: Thursday, January 09, 2003 4:11 PM
> To: Lorn Kay
> Cc: nfs@lists.sourceforge.net; linux-ha@muc.de
> Subject: [NFS] Re: NFS as a Cluster File System.
>
> >     Linux clients can use TCP instead of UDP.
> 
> Although I haven't had problems with this in our lab, I 
> believe the NFS authors still consider this experimental.

the Linux NFS client support for TCP is not experimental.
perhaps less mature than UDP, but definitely not experimental.

the server, OTOH, sports brand new support for TCP.  is that
what you were referring to?


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
