From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFSv4 on linux 2.4.x
Date: Thu, 31 Jul 2003 07:01:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127ED0@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iE2z-0003kr-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 07:04:49 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h6VE4iQw015132
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 07:04:44 -0700 (PDT)
Received: from black.eng.netapp.com (black.eng.netapp.com [10.56.10.24])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id h6VE4hRa028362
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 07:04:43 -0700 (PDT)
To: "'Alain FORCIOLI'" <alain.forcioli@cyber-networks.fr>
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

"stable" refers to the use of the 2.4 kernel rather than
the development kernel.  in fact, it is more stable than
the same code living in the 2.5/6 kernels because it has
been more thoroughly tested.

the NFSv4 on Linux 2.4 implementation is beta quality and
is not intended for production environments, only for
testing.  Linux NFSv4 itself doesn't support delegation,
file migration, NFSv4 state recovery, or locking.  all
these are yet to be implementated in 2.6 kernels, but we
expect them in the coming months.

note that there are no feature-complete NFSv4 implementations
available from any vendor for production use at the moment.  

> -----Original Message-----
> From: Alain FORCIOLI [mailto:alain.forcioli@cyber-networks.fr] 
> Sent: Thursday, July 31, 2003 8:50 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFSv4 on linux 2.4.x
> 
> 
> Hello,
> 
> I'm looking for success uses of NFSv4 client on linux 2.4 in a
> production environment.
> 
> In the first section of "NFS version 4 for Linux 2.4, Release Two"
> (https://linux24-nfsv4.citi.umich.edu/wiki?p=ReleaseTwoReleaseNotes) I
> can read that the NFSv4 implementation for linux 2.4 is beta quality.
> But I can read in other documents that this is a stable 
> implementation.
> 
> Thank you for your help.
> -- 
> Alain FORCIOLI
> 
> 
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet
> _072303_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
