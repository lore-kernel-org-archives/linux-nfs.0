From: Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
Subject: Re: Millions of files and directory caching.
Date: Wed, 23 Oct 2002 21:48:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023214857.61d6689d.philippe.gramoulle@mmania.com>
References: <D38AFB3080F3D311807300B0D0203E53033A92D8@MERCURY>
	<3DB6E791.2030304@chrisdos.com>
	<20021023142540.A28378@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.aspic.com ([213.193.2.5] helo=off.aspic.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RV3-0008Kl-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 12:49:06 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20021023142540.A28378@redhat.com>
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

Re,

Chris, you might be also interested in this pretty clever hardlinks/rsync snapshot system:

http://www.mikerubel.org/computers/rsync_snapshots/

Philippe.

On Wed, 23 Oct 2002 14:25:40 -0400
Benjamin LaHaise <bcrl@redhat.com> wrote:

  |  LVM has the ability to create block device level snapshots, but it exacts 
  |   a performance hit.  Just how much depends on the configuration of the 
  |   array and whether the snapshot slices are allocated from a different 
  |   drive.  It works quite well with ext3, although you have to make sure 
  |   you mount the snapshots as ext2 read only.
  |  
  |   		-ben


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
