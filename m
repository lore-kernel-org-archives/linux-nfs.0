From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: exportfs nohide option for nfsv4
Date: Thu, 10 Mar 2005 20:29:31 -0800 (PST)
Message-ID: <20050311042931.74151.qmail@web51606.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9bmO-0004GI-5N
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 20:29:40 -0800
Received: from web51606.mail.yahoo.com ([206.190.38.211])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1D9bmM-0001HM-E6
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 20:29:40 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: 6667
Sender: nfs-admin@lists.sourceforge.net
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

Sorry , i was bit confused.
Its clear to me now.
Though server has exported parent and all child
filesystems , client has mounted only parent.
As client has not explicitly mounted child filesystem,
child filesystem is not accessible to it(client) 
and so to make it accessible nohide option should be
used so that child need not be mounted separately or
explicitly by client.


thanks for your replies,
 --kiran


--- "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Mar 10, 2005 at 07:43:33AM -0800, mehta
> kiran wrote:
> > 1. Normally,  if  a  server
> > 2. exports  two filesystems one of which is
> mounted 3.
> > on the other, then the client will have to mount  
> > 4. both filesystems  explicitly  to get access to
> > 5. them.  If it just mounts the parent, it  will 
> see 
> > 6. an  empty directory  at  the place where the
> other
> > 7. filesystem is mounted.  That filesystem is 
> > 8. hidden".
> > 9. Setting the nohide option on a filesystem
> causes
> > 10.it not  to  be hidden.
> > 
> > from lines 5-10 i understand that if client mounts
> > only parent directory , child directory is hidden
> > to client.To make this accessbile to client ,
> exportfs
> > should use nohide option , but in
> > my example i have explicitly exported child 
> > directory.
> 
> Note the first sentence: "if a server exports two
> filesystems
> one of which is mounted on the other..."
> 
> So the man page is dealing with exactly you
> case--when you
> have explicitly exported both the parent and the
> child.  I'm
> not sure how the man page could be made clearer.
> 
> --b.
> 
> 
>
-------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT
> Products from real users.
> Discover which products truly live up to the hype.
> Start reading now.
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


		
__________________________________ 
Do you Yahoo!? 
Make Yahoo! your home page 
http://www.yahoo.com/r/hs


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
