From: "=?iso-8859-1?q?Mark=20A.=20Tagliaferro?=" <be_lak@yahoo.co.uk>
Subject: Re: Unable to connect to NFS Server - mountd crashing
Date: Thu, 9 Oct 2003 09:42:23 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031009084223.32362.qmail@web86006.mail.ukl.yahoo.com>
References: <08df01c38ce5$8398e260$6401a8c0@Matt>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7WNr-0001ko-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Oct 2003 01:42:55 -0700
Received: from web86006.mail.ukl.yahoo.com ([217.12.12.37])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A7WNq-0002bD-Js
	for nfs@lists.sourceforge.net; Thu, 09 Oct 2003 01:42:54 -0700
To: Matt Heaton <admin@0catch.com>
In-Reply-To: <08df01c38ce5$8398e260$6401a8c0@Matt>
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

Excuse my ignorance, but what exactly is a reverse lookup? Anyway I did not
change any settings.  The NFS server has been working happily for the last year
and a half.  The only thing that changed was that the hardrive containing the
data i want to share was not in the server because there were some bad sector
problems.  I copied the data onto another harddrive and inserted the new
harddrive.

I tried removing it again but still montd is crashing.

Mark
 --- Matt Heaton <admin@0catch.com> wrote: > Did you just change the reverse
lookup on the IP of the client or server?
> They have to match you know.
> If you just added a reverse lookup and not a forward lookup sometimes it
> will do this.
> 
> Matt
> 
> 
> ----- Original Message ----- 
> From: "Mark A. Tagliaferro" <be_lak@yahoo.co.uk>
> To: <nfs@lists.sourceforge.net>
> Sent: Tuesday, October 07, 2003 4:51 AM
> Subject: [NFS] Unable to connect to NFS Server - mountd crashing
> 
> 
> > Hi all,
> >
> > This is driving me nuts because up to yesterday the system was working but
> > suddenly it went berserk.  I'm trying to connect to m NFS shares on my
> SuSE 7.1
> > server and I'm getting the following error:
> >
> > mount: RPC: Unable to receive; errorno = Connection refused
> >
> > After a lot of investigation I stumbled on what is happening.  When the
> nfs
> > server is started, 'nfsserver status' gives me 'NFS Server is up'.  When I
> > check with rpcinfo -p server I see portmap, mountd, nfs and ypbind (i'm
> using
> > NIS as well which is still working).
> >
> > When I try to connect from the client and get the error message something
> > really weird happens on the server. 'nfsserver status' returns 'NFS server
> > down' and rpcinfo -p server doesn't show mountd anymore.
> >
> > I figure that somehow when the call is made mountd is crashing thus
> shutting
> > down the nfs server.
> >
> > Any idea of why this is happening or how to solve it?
> >
> > ________________________________________________________________________
> > Want to chat instantly with your online friends?  Get the FREE Yahoo!
> > Messenger http://mail.messenger.yahoo.co.uk
> >
> >
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
>  

________________________________________________________________________
Want to chat instantly with your online friends?  Get the FREE Yahoo!
Messenger http://mail.messenger.yahoo.co.uk


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
