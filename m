From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: problem with  umount
Date: Fri, 28 Jan 2005 19:13:14 -0800
Message-ID: <1106968394.10024.27.camel@lade.trondhjem.org>
References: <20050128123730.4865.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cuj3D-0002tl-Fq
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:13:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cuj3B-0005tW-Me
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:13:31 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050128123730.4865.qmail@web51602.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

fr den 28.01.2005 Klokka 04:37 (-0800) skreiv mehta kiran:

> But if client stays without doing any processing ,
> everything works fine.
> I tried using umount <filesystem> -O -l
> but this does not work though man pages 
> say that even if there are reference to filesystem , 
> it will be unmounted and later do required cleanup.

>From the manpage for "umount":

      -O options
              Indicate  that  the actions should only be taken on file systems
              with the specified options in /etc/fstab.  More than one  option
              type  may  be  specified in a comma separated list.  Each option
              can be prefixed with no to specify options for which  no  action
              should be taken.

AFAIK, there is no "-l" _mount_ option, so it is extremely unlikely that
your NFS-mounted filesystems are listed in /etc/fstab as using it.
You're better off trying with "umount -l /filesystem".

Better still, fix your init scripts so that they kill whatever process
it is that is still using the NFS partition and causing the regular
"umount" to fail: *NIX does NOT allow you to unmount partitions that are
*in use*.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
