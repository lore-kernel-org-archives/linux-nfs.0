From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: of rmtab and 'Invalid argument' and permission denied]
Date: Fri, 14 Mar 2003 13:32:05 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15985.16165.514501.452356@notabene.cse.unsw.edu.au>
References: <20030309213151.GK747@gallifrey>
	<3E708B14.1060000@treblig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18tf0O-0000OJ-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Mar 2003 18:33:08 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <gilbertd@treblig.org>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 14 Mar 2003 13:32:24 +1100
To: "Dave Gilbert (Home)" <gilbertd@treblig.org>
In-Reply-To: message from Dave Gilbert (Home) on Thursday March 13
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

On Thursday March 13, gilbertd@treblig.org wrote:
> Neil Brown wrote thus:
> 
>     that I wrote:
> >>Sometimes the client will get a permission denied on attempting to mount
> >>from the server even though it managed it a few hours earlier with no
> >>change to config of the server.
> >>
> >>Restarting the nfs server gives a line of the form:
> >>
> >>clienthostname: Invalid argument
> 
> > What does your /etc/exports file look like?  Does it have both host
> > names and IP addresses?  
> > Do you export both a directory and an ancestor of that directory on
> > the same filesystem?
> > 
> > Both of these can cause this sort of problem.
> 
> Thank you!  It was exporting both a directory and an ancestor.
> Can we have something which screams/shouts/warns/rejects this
> rather than failing in an evil and confusing way?

It would be nice.... but I'm currently more interested in getting
nfs-utils to support the new interfaces in 2.5...

> 
> (oh and add it to the NFS FAQ)

Isn't it there??? Should be added then.

> 
> > What version of nfs-utils is in SuSE 8.1?
> > 
> >  showmount -v
> 
> showmount for nfs-utils 0.3.3

Thats getting a bit old. 1.0 have been out for a while and fixed the
problem I hinted related to host-names and IP addresses in the same
/etc/exports file.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
