From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Tue, 24 Feb 2004 15:10:34 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16442.52922.613916.868991@notabene.cse.unsw.edu.au>
References: <40188282.36FBA905@melbourne.sgi.com>
	<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
	<403ACE01.2BBF39D6@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvTuV-0002t4-1i
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 20:11:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvTu3-00042c-Ls
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 20:10:39 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Tue, 24 Feb 2004 15:10:36 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday February 24
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

On Tuesday February 24, gnb@melbourne.sgi.com wrote:
> 
> Aha, it's embarrassment time.  Since sending the patch I've discovered
> that this part
> 
> > > +instead of a number derived from the major and minor number of the
> > > +block device on which the filesystem is mounted.  Any 32 bit number
> > > +can be used, but it must be unique amongst all the exported filesystems.
> 
> is wrong; the fsid passes through a dev_t interface and is silently
> truncated to 16 bits.  The following fixes my gaffe.  Sorry.
> 

Hmm... I'd much rather we actually used 32 bits.  Where does the
truncate happen?  nfs-utils / kernel-2.4 / kernel-2.6 ??

NeilBrown

> 
>  --- utils/exportfs/exports.man.orig	Tue Feb 24 15:06:35 2004
> +++ utils/exportfs/exports.man	Tue Feb 24 15:06:38 2004
> @@ -277,7 +277,7 @@
>  handle and file attributes used on the wire to be
>  .I num
>  instead of a number derived from the major and minor number of the
> -block device on which the filesystem is mounted.  Any 32 bit number
> +block device on which the filesystem is mounted.  Any 16 bit number
>  can be used, but it must be unique amongst all the exported filesystems.
>  
>  This can be useful for NFS failover, to ensure that both servers of
> 
> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
