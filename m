From: Greg Banks <gnb@sgi.com>
Subject: Re: Converting open filehandles to pathnames
Date: Sun, 9 May 2004 17:24:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040509072418.GB18762@sgi.com>
References: <1084059203.714.13.camel@omikron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMiug-0003E7-Sc
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 00:39:54 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BMiug-0008Am-Oo
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 00:39:54 -0700
To: Erik Walthinsen <omega@pdxcolo.net>
In-Reply-To: <1084059203.714.13.camel@omikron>
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

On Sat, May 08, 2004 at 04:33:28PM -0700, Erik Walthinsen wrote:
> I've got an NFS server with client machines running User-mode Linux. 
>[...]
> My question: is there some means of divining the device/inode of a
> filehandle?  I looked around the NFS and VFS code and found nothing that
> looked promising, but I don't really understand the VFS subsystem.

Generally the device and inode of the file are encoded in the
file handle itself rather than mapped in the server; this is
the easiest way of satisfying the requirement that the filehandles
be stable across server reboots.

If your NFS server is a Linux box, see the comments in
include/linux/nfsd/nfsfh.h for a description of the format
of Linux' file handles.

Also, ethereal will pick apart and display Linux file handles
(unless the underlying server fs is XFS).

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
