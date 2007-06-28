From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv4 uninitialized mtime
Date: Thu, 28 Jun 2007 09:19:45 -0400
Message-ID: <1183036785.6163.14.camel@heimdal.trondhjem.org>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<20070628064127.a769bc53.jlayton@redhat.com>
	<20070628080108.020ac237.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3tuh-00076c-L0
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 06:19:59 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19QNcOvzJXVio5kREEWEsr+KD8NuRR5/no=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3tuj-0005co-Ev
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 06:20:03 -0700
In-Reply-To: <20070628080108.020ac237.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-06-28 at 08:01 -0400, Jeff Layton wrote:
> Yes, it looks like Solaris is sending back a zeroed out attrmask on
> exclusive create. I'm testing against:
> 
>                             Solaris Nevada snv_54 X86
>            Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
>                         Use is subject to license terms.
>                            Assembled 04 December 2006
> 
> SunOS solaris 5.11 snv_54 i86pc i386 i86pc
> 
> My guess is that they're using NFSv3 semantics in their NFSv4 client to
> set the mtime and atime, and that's why it "works" there. This patchrev
> is pretty old by now, so they may have already patched this issue. I'll
> see if I can patch it and test again.
> 
> All this, of course, is contingent upon my having interpreted the spec
> correctly. I think I have, but wouldn't mind if someone sanity checked
> me on it.

The only nit I can see is that the server is in theory allowed to store
the cookie in some writable attribute other than atime/mtime, but I
can't think of that many that would make sense. Perhaps time_backup and
time_create for those servers that support them? However since we don't
care about their values and since they don't support a
SET_TO_SERVER_TIME4 option, I'm not sure we want to bother...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
