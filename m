From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Millions of files and directory caching.
Date: Wed, 23 Oct 2002 14:25:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023142540.A28378@redhat.com>
References: <D38AFB3080F3D311807300B0D0203E53033A92D8@MERCURY> <3DB6E791.2030304@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184QCM-0005S6-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 11:25:42 -0700
To: Chris Dos <chris@chrisdos.com>
In-Reply-To: <3DB6E791.2030304@chrisdos.com>; from chris@chrisdos.com on Wed, Oct 23, 2002 at 12:16:49PM -0600
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

On Wed, Oct 23, 2002 at 12:16:49PM -0600, Chris Dos wrote:
> Now if I can just come up with a way to make it do snapshots like a 
> Netapp I'd be set.  I heard that the Linux Volume Manager has this 
> capability.  Does anyone know if this is true?  Back in 1999 there as a 
> snapfs project that was started, but I don't think it ever got off the 
> ground.

LVM has the ability to create block device level snapshots, but it exacts 
a performance hit.  Just how much depends on the configuration of the 
array and whether the snapshot slices are allocated from a different 
drive.  It works quite well with ext3, although you have to make sure 
you mount the snapshots as ext2 read only.

		-ben


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
