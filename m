From: Brian Jackson <brian@mdrx.com>
Subject: Re: NFS as a Cluster File System.
Date: Thu, 9 Jan 2003 16:04:07 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301091604.07132.brian@mdrx.com>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com> <3E1DE570.7070207@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.67.58.25] (helo=duallie.mdrx.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WkkI-0002qQ-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 14:01:50 -0800
To: nfs@lists.sourceforge.net, linux-ha@muc.de
In-Reply-To: <3E1DE570.7070207@emageon.com>
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

On Thursday 09 January 2003 03:11 pm, Brian Tinsley wrote:
> Lorn Kay wrote:
> > Is NFS a viable CFS? (I'm cross posting this due to a discussion on
> > the the linux-ha list recently.)
>
> Since there is not a really good cluster filesystem for Linux that is
> not either "half baked"

Hey, we're working on it ;)

--Brian Jackson
OpenGFS Project

> (IMHO - I'm probably going to get smacked over
> that statement!) or cost an arm and a leg, this is exactly the route we
> have taken.
>
> >     The NFS server is a high-quality dedicated machine (Net App, EMC,
> > etc.)
>
> We've had great success with just using SMP Linux servers. We do have
> one EMC IP4700 in production, and it's a nice system, but I prefer the
> Linux based alternative.
>
> >     Linux clients can use TCP instead of UDP.
>
> Although I haven't had problems with this in our lab, I believe the NFS
> authors still consider this experimental.



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
