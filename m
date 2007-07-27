From: Garrick Staples <garrick@usc.edu>
Subject: Re: wonky autotools question
Date: Fri, 27 Jul 2007 13:29:35 -0700
Message-ID: <f606ea2d46f0.46a9f33f@usc.edu>
References: <46AA4BF6.6090002@oracle.com> <20070727200856.GI13965@fieldses.org>
	<46AA52C0.8060209@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEWRK-0000rm-RE
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:29:37 -0700
Received: from msg-mx5.usc.edu ([128.125.137.10] ident=sjes)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEWRM-0004ls-J3
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:29:38 -0700
Received: from msg-store0.usc.edu ([128.125.137.11])
	by msg-mx5.usc.edu (Sun Java System Messaging Server 6.2-7.05 (built
	Sep 5 2006)) with ESMTP id <0JLU006JMU9BXUD0@msg-mx5.usc.edu> for
	nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:29:35 -0700 (PDT)
Received: from usc.edu (localhost.usc.edu [127.0.0.1])
	by msg-store0.usc.edu (Sun Java System Messaging Server 6.2-7.05 (built
	Sep 5 2006)) with ESMTP id <0JLU00A2HU9B9F50@msg-store0.usc.edu> for
	nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:29:35 -0700 (PDT)
In-reply-to: <46AA52C0.8060209@oracle.com>
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



----- Original Message -----
From: Chuck Lever <chuck.lever@oracle.com>
Date: Friday, July 27, 2007 1:19 pm
Subject: Re: [NFS] wonky autotools question
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net

> J. Bruce Fields wrote:
> > On Fri, Jul 27, 2007 at 03:48:06PM -0400, Chuck Lever wrote:
> >> Hi all-
> >>
> >> It would be nice to enable more static code checking in nfs-
> utils (I'm 
> >> especially interested in utils/mount/).  Is there a clean way to 
> add 
> >> additional CFLAGS, like -Wall, to utils/mount/Makefile using the 
> autotools 
> >> set up?  How about a lint or sparse target?
> > 
> > I don't know, sounds like a good idea.
> 
> So far, "CFLAGS=-Wall -O2 -g ./configure" enables full warnings 
> everywhere in the tree, but I haven't found anything on how to 
> specify 
> additional CFLAGS in one subdir, and have it happen automatically.
> 
> > Last I checked, though, I thought there were still a fair number of
> > warnings just with the current defaults.  Maybe we should fix 
> those up
> > first?
> 
> I'm focusing on utils/mount at the moment, and that seems pretty 
> clean 
> with the present C flags.  I have noticed warnings in other parts 
> of the 
> tree, but haven't had time to poke at them.

In configure.ac, add something like this:
     GCC_WARNING_FLAGS="" 
     if test "x$GCC" = "xyes" ;then
        GCC_WARNING_FLAGS="-Wall -O2 -g"
     fi
     AC_SUBST(GCC_WARNING_FLAGS)

And then in utils/mount/Makefile.am, add something like this:
   mount_CFLAGS = $(GCC_WARNING_FLAGS)
  

This is a pretty generic answer because I haven't actually looked at the source tree to know if these are correct for your autotools stuff.  If you like, I can grab it and send you a patch.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
