From: David Myer <davidmyer800@yahoo.com>
Subject: Re: nfs over tcp in linux kernel version 2.4.18
Date: Wed, 21 May 2003 10:25:02 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030521172502.29772.qmail@web21002.mail.yahoo.com>
References: <20030520212029.77226.qmail@web21006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web21002.mail.yahoo.com ([216.136.227.56])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IXKo-0006nn-00
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 10:25:02 -0700
To: David Myer <davidmyer800@yahoo.com>,
  Dan Brunner <daniel.brunner@duni.com>, guolin@alexa.com
In-Reply-To: <20030520212029.77226.qmail@web21006.mail.yahoo.com>
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

Any thoughts on my questions guys ? Would appreciate
any information.

Also, will 2.4.18 kernel as nfs client work with
2.4.20 kernel as nfs server if trying to tcp ? Anyone
have tried this ?

David
--- David Myer <davidmyer800@yahoo.com> wrote:
> Thanks for the information guys,
> 
> Looking at svcsock.c in 2.4.18/linux/net/sunrpc/
> it does seem to have STREAM type of socket support.
> if I just want to do basic mount/ls/vi type of
> operations, which patch do I actually need or is
> there
> a comiple switch to set during kernel compilation
> time
> just to enable TCP support on sever side ? Client
> side
> definitely has this by looking at xprt.c code..
> 
> Thanks again
> David
> --- Dan Brunner <daniel.brunner@duni.com> wrote:
> > Guolin,
> > 
> > That DOES sound like a pain in the a$$!!!!!!!
> > 
> > And yes your right, not everyone has the same
> > success...
> > 
> > Good Luck!!
> > 
> > 
> > Dan
> > 
> > 
> > On Tuesday, May 20, 2003, at 02:19  PM,
> > guolin@alexa.com wrote:
> > 
> > > Dan,
> > >
> > >  try your luck.
> > >
> > >  BTW, let you know that I have to take the pain
> to
> > reboot 400 Linux 
> > > boxes to
> > > get rid of "nfs over tcp" in our production
> > environment.
> > >
> > >  --Guolin Cheng
> > >
> > > -----Original Message-----
> > > From: Dan Brunner
> [mailto:daniel.brunner@duni.com]
> > > Sent: Tuesday, May 20, 2003 12:14 PM
> > > To: Guolin Cheng
> > > Cc: davidmyer800@yahoo.com;
> > nfs@lists.sourceforge.net
> > > Subject: Re: [NFS] nfs over tcp in linux kernel
> > version 2.4.18
> > >
> > >
> > > Guolin,
> > >
> > > I can't seem to agree with this...
> > >
> > > Maybe I don't have that many connections (17),
> but
> > I've been running
> > > NFS over TCP since 2.4.18. And I haven't had
> once
> > MAJOR crash yet!! My
> > > clients however, are all Mac OS X clients.
> > 10.0.4-10.2.6.
> > >
> > > Maybe that has something to do with it....
> > >
> > >
> > > And we don't get a lot of hangs either....
> > >
> > >
> > > later
> > >
> > >
> > > Dan
> > >
> > >
> > > On Tuesday, May 20, 2003, at 01:41  PM,
> > guolin@alexa.com wrote:
> > >
> > >> David,
> > >>
> > >>  "nfs over tcp" is terribly unstable until now,
> I
> > use version 2.4.20,
> > >> and
> > >> find that over 30 simultaneous nfs connection
> can
> > kill an "nfs over
> > >> tcp"
> > >> Linux nfs server easily. let clients' processes
> > hangs there forever.
> > >> But
> > >> this didn't happen for Linux nfs server
> enabling
> > only "nfs over udp".
> > >>
> > >>  So the best choice now is totally disregard
> > Linux "nfs over tcp" in
> > >> production environment. just try it in research
> > environment.
> > >>
> > >>  Thanks.
> > >>  --Guolin Cheng
> > >>
> > >>
> > >> -----Original Message-----
> > >> From: David Myer
> [mailto:davidmyer800@yahoo.com]
> > >> Sent: Tuesday, May 20, 2003 11:03 AM
> > >> To: nfs@lists.sourceforge.net
> > >> Subject: [NFS] nfs over tcp in linux kernel
> > version 2.4.18
> > >>
> > >>
> > >> Hi,
> > >>
> > >> Can anyone advise me if nfs server over tcp is
> > >> supported in 2.4.18 kernel version ? How to
> > >> setup/enable on both server/client side ? Tried
> > to
> > >> looked at FAQ but information did not seem be
> > there.
> > >>
> > >> Do I need to apply any patches ?
> > >>
> > >> Thanks
> > >> David
> > >>
> > >> __________________________________
> > >> Do you Yahoo!?
> > >> The New Yahoo! Search - Faster. Easier. Bingo.
> > >> http://search.yahoo.com
> > >>
> > >>
> > >>
> >
>
-------------------------------------------------------
> > >> This SF.net email is sponsored by: ObjectStore.
> > >> If flattening out C++ or Java code to make your
> > application fit in a
> > >> relational database is painful, don't do it!
> > Check out ObjectStore.
> > >> Now part of Progress Software.
> > http://www.objectstore.net/sourceforge
> > >> _______________________________________________
> > >> NFS maillist  -  NFS@lists.sourceforge.net
> > >>
> https://lists.sourceforge.net/lists/listinfo/nfs
> > >>
> > >>
> > >>
> >
>
-------------------------------------------------------
> > >> This SF.net email is sponsored by: ObjectStore.
> > >> If flattening out C++ or Java code to make your
> > application fit in a
> > >> relational database is painful, don't do it!
> > Check out ObjectStore.
> > >> Now part of Progress Software.
> > http://www.objectstore.net/sourceforge
> > >> _______________________________________________
> > >> NFS maillist  -  NFS@lists.sourceforge.net
> > >>
> https://lists.sourceforge.net/lists/listinfo/nfs
> > 
> > 
> > 
> >
>
-------------------------------------------------------
> > This SF.net email is sponsored by: ObjectStore.
> > If flattening out C++ or Java code to make your
> > application fit in a
> > relational database is painful, don't do it! Check
> > out ObjectStore.
> > Now part of Progress Software.
> > http://www.objectstore.net/sourceforge
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Search - Faster. Easier. Bingo.
> http://search.yahoo.com
> 
> 
>
-------------------------------------------------------
> This SF.net email is sponsored by: ObjectStore.
> If flattening out C++ or Java code to make your
> application fit in a
> relational database is painful, don't do it! Check
> out ObjectStore.
> Now part of Progress Software.
> http://www.objectstore.net/sourceforge
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> 
=== message truncated ===

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
