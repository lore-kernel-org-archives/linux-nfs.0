From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exportfs nohide option for nfsv4
Date: Thu, 10 Mar 2005 11:00:07 -0500
Message-ID: <20050310160007.GA12787@fieldses.org>
References: <20050310154334.34824.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9Q4g-0001ny-BA
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:59:46 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D9Q4e-0007T6-TW
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:59:46 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050310154334.34824.qmail@web51607.mail.yahoo.com>
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

On Thu, Mar 10, 2005 at 07:43:33AM -0800, mehta kiran wrote:
> 1. Normally,  if  a  server
> 2. exports  two filesystems one of which is mounted 3.
> on the other, then the client will have to mount  
> 4. both filesystems  explicitly  to get access to
> 5. them.  If it just mounts the parent, it  will  see 
> 6. an  empty directory  at  the place where the other
> 7. filesystem is mounted.  That filesystem is 
> 8. hidden".
> 9. Setting the nohide option on a filesystem causes
> 10.it not  to  be hidden.
> 
> from lines 5-10 i understand that if client mounts
> only parent directory , child directory is hidden
> to client.To make this accessbile to client , exportfs
> should use nohide option , but in
> my example i have explicitly exported child 
> directory.

Note the first sentence: "if a server exports two filesystems
one of which is mounted on the other..."

So the man page is dealing with exactly you case--when you
have explicitly exported both the parent and the child.  I'm
not sure how the man page could be made clearer.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
