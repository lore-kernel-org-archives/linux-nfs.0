From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFSv4 uninitialized mtime
Date: Thu, 28 Jun 2007 08:01:08 -0400
Message-ID: <20070628080108.020ac237.jlayton@redhat.com>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<20070628064127.a769bc53.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3sgb-0007fU-0u
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 05:01:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3sge-0007Mf-6Q
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 05:01:24 -0700
In-Reply-To: <20070628064127.a769bc53.jlayton@redhat.com>
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

On Thu, 28 Jun 2007 06:41:27 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 27 Jun 2007 19:53:27 -0700
> Stuart Anderson <anderson@ligo.caltech.edu> wrote:
> 
> > On Wed, Jun 27, 2007 at 09:15:59PM -0400, Jeff Layton wrote:
> > > On Wed, 27 Jun 2007 17:59:57 -0700
> > > Stuart Anderson <anderson@ligo.caltech.edu> wrote:
> > > 
> > > > More precisely, applying this patch to the 2.6.20.14 kernel plus the
> > > > revalidate-the-fsid patch did not result in any changes. Does the
> > > > O_EXCL patch require some other supporting patches relative to 2.6.20.14?
> > > > 
> > > > or perhaps it is necessary to rebase to a newer kernel before applying it?
> > > > even tough it applies, builds and runs with 2.6.20.14?
> > > > 
> > > > Thanks.
> > > > 
> > > 
> > > With Linux, both client and server side were broken in this respect.
> > > The server didn't set the bitmask in the reply and the client didn't
> > > look at it anyway. It's possible that Solaris server is broken in this
> > > regard as well. It would be interesting to see a capture here,
> > > particularly one containing the reply from the CREATE.
> > 
> > Possible, but when we switch the client from Linux to Solaris and share
> > the same filesytem from the same server there are no O_EXCL problems.
> > 
> 
> NFSv3 didn't use this bitmask, so clients tended to just clobber the
> mtime and atime on the subsequent setattr. It's possible that Solaris
> is using the old semantics here with NFSv4. Of course, all of this is
> speculation :-), a capture should give us a better clue.
> 

Yes, it looks like Solaris is sending back a zeroed out attrmask on
exclusive create. I'm testing against:

                            Solaris Nevada snv_54 X86
           Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
                        Use is subject to license terms.
                           Assembled 04 December 2006

SunOS solaris 5.11 snv_54 i86pc i386 i86pc

My guess is that they're using NFSv3 semantics in their NFSv4 client to
set the mtime and atime, and that's why it "works" there. This patchrev
is pretty old by now, so they may have already patched this issue. I'll
see if I can patch it and test again.

All this, of course, is contingent upon my having interpreted the spec
correctly. I think I have, but wouldn't mind if someone sanity checked
me on it.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
