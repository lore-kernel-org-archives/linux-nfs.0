From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 900985: fix nohide export option for nfsv3
Date: Thu, 16 Oct 2003 10:40:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16269.59642.406190.261861@notabene.cse.unsw.edu.au>
References: <3F7CF147.B778D07B@melbourne.sgi.com>
	<16266.17267.491587.121802@notabene.cse.unsw.edu.au>
	<3F8A58E9.9A5D3102@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9wC6-0006ig-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Oct 2003 17:40:46 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A9wC4-0002Py-Sx
	for nfs@lists.sourceforge.net; Wed, 15 Oct 2003 17:40:45 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Thu, 16 Oct 2003 10:40:28 +1000
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Monday October 13
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

On Monday October 13, gnb@melbourne.sgi.com wrote:
> Neil Brown wrote:
> > 
> > On Friday October 3, gnb@melbourne.sgi.com wrote:
> > > G'day,
> > >
> > > --- /usr/tmp/TmpDir.24872-0/linux/linux/fs/nfsd/vfs.c_1.47    Fri Sep 19 20:12:50 2003
> > > +++ linux/linux/fs/nfsd/vfs.c Fri Sep 19 20:08:03 2003
> > > @@ -86,7 +86,7 @@
> > >   * accepted as it stands and the mounted directory is
> > >   * returned. Otherwise the covered directory is returned.
> > >   * NOTE: this mountpoint crossing is not supported properly by all
> > > - *   clients and is explicitly disallowed for NFSv3
> > > + *   clients.
> > >   *      NeilBrown <neilb@cse.unsw.edu.au>
> > 
> > This isn't quite right.  What the comment *Should* say is:
> >  ... and RFC1813 explicitly dis-allows it for NFSv3 (See section 3.3.3).
> 
> RFC1813 section 3.3.3 says...
> 
> > A server will not allow a LOOKUP operation to cross a mountpoint
> > to the root of a different filesystem, even if the filesystem is
> > exported.
> > [...]
> > A given server implementation may refine these rules given
> > capabilities or limitations particular to that implementation.
> > Refer to [X/OpenNFS] for a discussion on exporting file systems.
> 
> Reads to me like there's a loophole designed specifically for the
> nohide option.

So it does.  I guess I never read that far, and mistakenly read
"A server will not allow..." as "A server SHALL not allow..." :-)

> 
> The thing is, we have customers moving from Irix systems with an "sgi"
> logo on the front to Linux systems with an "sgi" logo on the front; they
> see the "nohide" option like they're used to and (poor naive creatures)
> expect it to work.  Having it work on v2 and silently fail on v3 is
> really submarvellous.

Certainly there is no suggestion of not supporting it for V3.  The
comment was just meant to say that we weren't allowed to support it,
but that we didn't.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
