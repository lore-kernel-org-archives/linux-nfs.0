From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: broken umount -f
Date: Tue, 14 Jan 2003 11:36:29 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D551EB@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWrX-00049j-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:36:39 -0800
To: "'Scott Mcdermott'" <smcdermott@questra.com>
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
> From: Scott Mcdermott [mailto:smcdermott@questra.com]
> Sent: Tuesday, January 14, 2003 2:20 PM
> To: Trond Myklebust
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Re: broken umount -f
> 
> Last I checked, the programs wouldn't die even with -KILL 
> when they were
> stuck in device-wait state.  The only way to reboot a machine 
> with such
> processes is to reboot -f, which is wrong.  The filesystems should be
> able to have forced umount at sysadmin's discretion.

do you remember which kernel this was?

trond fixed a long-standing "processes stuck in 'D' state" bug in
2.4.20.  this bug may be the reason these processes didn't die
when you killed them.


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
