From: Neil Brown <neilb@suse.de>
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 10:43:27 +1000
Message-ID: <17240.14767.472971.724098@cse.unsw.edu.au>
References: <E1ESjPp-0004BW-Qv@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESl0U-0005xv-LA
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 17:43:38 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESl0T-0006O2-E9
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 17:43:38 -0700
To: petter.knutsen@cgi.no
In-Reply-To: message from petter.knutsen@cgi.no on Friday October 21
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

On Friday October 21, petter.knutsen@cgi.no wrote:
> Hello,
> 
> I have a question about NFS and file locking on multiple clients.
> 
> Let's say I have a NFS server and two clients; "client a" and "client b". Is
> it possible to flock() a file on "client a", and make "client b" respect a's
> lock?
> 
> I've managed to lock files on "client a" and let other processes on "client
> a" honour the locks, but "client b" doesn't seem to be able to see the locks.
> 
> 
> Before I research any further, does anyone know if this is possible?

Check the man page:  "man flock":

NOTES
       flock(2) does not lock files over NFS.  Use fcntl(2) instead: that does
       work  over  NFS,  given  a  sufficiently  recent version of Linux and a
       server which supports locking.

Use fcntl or lockf (which is wrapper for fcntl) if you want to lock
over NFS.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
