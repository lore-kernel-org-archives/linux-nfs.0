From: AK <amithl_prem@yahoo.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Thu, 8 Mar 2007 06:55:50 -0800 (PST)
Message-ID: <121929.1837.qm@web56610.mail.re3.yahoo.com>
References: <45EF3F20.5060300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPK28-0002Su-8N
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 06:55:56 -0800
Received: from web56610.mail.re3.yahoo.com ([66.196.97.54])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HPK29-0004Td-04
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 06:55:58 -0800
In-Reply-To: <45EF3F20.5060300@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--- Peter Staubach <staubach@redhat.com> wrote:

> >>>       
> >> What about this application requires that the
> "noac"
> >> option be used?
> >>     
> >   application is romio with mpich2 ...
> 
> Sorry, I'm not familiar with those.  What about
> either one of those
> require "noac" semantics?

"To use ROMIO on NFS, file locking with fcntl must
work correctly on the NFS installation. On some
installations, fcntl locks don't work. To get them to
work, you need to use Version 3 of NFS, ensure that
the lockd daemon is running on all the machines, and
have the system administrator mount the NFS file
system with the "noac" option (no attribute caching).
Turning off attribute caching may reduce performance,
but it is necessary for correct behavior."

> 
> >> One of the impacts of using the "noac" option is
> >> much more network
> >> traffic and it will be composed of small packets.
> 
> >> If the server is
> >> busy handling all of the additional GETATTR
> >> requests, then it won't
> >> be handling other requests.  The client will also
> be
> >> a bit busier
> >> with generating the additional requests, instead
> of
> >> just doing what
> >> might be considered more useful work.
> >>
> >> So, there should be no direct impact to other
> >> mounted file systems.
> >> However, there may be indirect impacts.
> >>     
> >
> > indirect impacts: can you please elaborate on
> this.
> 
> I thought that I did.  :-)
> 
> If the system is busy handling the "noac" aspects of
> one file system,
> then it isn't doing something else on one of the
> other file systems.
> System resources are limited and using up more of
> them for one thing
> leaves less for others.

Got it!!! when you mentioned "However, there may be
indirect impacts." in the last line, i was like there
could be more, and hence curious :-) 

> 
>        ps
> 



 
____________________________________________________________________________________
The fish are biting. 
Get more visitors on your site using Yahoo! Search Marketing.
http://searchmarketing.yahoo.com/arp/sponsoredsearch_v2.php

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
