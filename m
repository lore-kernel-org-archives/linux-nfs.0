From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Re: Converting open filehandles to pathnames
Date: Sat, 08 May 2004 17:43:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084063428.714.40.camel@omikron>
References: <1084059203.714.13.camel@omikron>
	 <20040509072418.GB18762@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMjI8-0005M8-5v
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 01:04:08 -0700
Received: from [216.99.212.251] (helo=mail.omegacs.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMjI7-0007Cb-Nv
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 01:04:07 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040509072418.GB18762@sgi.com>
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

On Sun, 2004-05-09 at 00:24, Greg Banks wrote:
> Generally the device and inode of the file are encoded in the
> file handle itself rather than mapped in the server; this is
> the easiest way of satisfying the requirement that the filehandles
> be stable across server reboots.
Oh.  Duh.  I was assuming the filehandles were randomly assigned by the
server, didn't think about the requirements filehandle continuity would
impose...  I suppose it's just plain cheaper too.

> If your NFS server is a Linux box, see the comments in
> include/linux/nfsd/nfsfh.h for a description of the format
> of Linux' file handles.
Heh, found the inode in the filehandle in ethereal just by inspection,
will have to hack my script tomorrow to make use of it.

> Also, ethereal will pick apart and display Linux file handles
> (unless the underlying server fs is XFS).
The version I have (debian/sid ethereal-0.10.3) doesn't display
filehandles as anything but length and data, though I have used the mode
that does what my script was trying to do, which will try to find and
cache the translation.  However, that only works when the getattrs are
present <g>  Not sure if running ethereal on the NFS server itself would
help, but it's got no head and no X anyway.

Well, I think my problem is solved, thanks for the help! ;-)

Now if someone just had as good an answer to the "what is a client?"
question....  You might imagine my interest in that is more than
academic, with 100's of *long*-duration filehandles in the GB+ range
each, yet over only a few physical client machines.

Thanks,
      Omega
      aka Erik Walthinsen
      omega@pdxcolo.net



-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
