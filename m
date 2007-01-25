From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Lucene, delete-on-last-close, and flock emulation
Date: Wed, 24 Jan 2007 19:06:58 -0800
Message-ID: <1169694418.8355.5.camel@lade.trondhjem.org>
References: <873E10FD-9682-46D8-9A5D-D6AD6C60060C@rectangular.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Marvin Humphrey <marvin@rectangular.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9uxE-0004XD-Ti
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 19:07:13 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18xS5cw2QFZSLm3QwCDwuzesnCsBc/b1ys=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9uxF-00075z-Th
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 19:07:14 -0800
In-Reply-To: <873E10FD-9682-46D8-9A5D-D6AD6C60060C@rectangular.com>
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

On Wed, 2007-01-24 at 14:04 -0800, Marvin Humphrey wrote:
> Greetings,
> 
> The Apache Lucene search engine library currently suffers from a  
> design flaw that causes problems when indexes located on NFS volumes  
> are updated.  The same flaw afflicts my Perl/C port of Lucene,  
> KinoSearch.  My goal is to eliminate the problem for both libraries.   
> I hope that someone subscribed to this list can help by clarifying  
> one item from the FAQ, and possibly offering further guidance.
> 
> Lucene depends upon delete-on-last-close semantics.
> 
> Lucene indexes are comprised of many files.  Once written, no files  
> are ever modified -- instead, they are rendered obsolete when more  
> recent versions arrive.  Which files are the most recent can be  
> determined by examining a base-36 numerical increment embedded in the  
> file name: "foo_z53" is more recent than "foo_z52".
> 
> When an index-reading app is created, it opens the most recent set of  
> files available, and never updates.  If new files are written, the  
> reader won't know about them; it stays focused on the snapshot that  
> was present at its moment of creation.
> 
> Index-writing applications, once they have completed writing a set of  
> updated files, unlink any files which are now "obsolete".  If a  
> reader still happens to be using one of these "obsolete" files,  
> delete-on-last-close ordinarily prevents the reader from being cut  
> off from the needed resource.
> 
> On NFS, this design breaks, since NFS does not support delete-on-last- 
> close.  When the index-writing application deletes an "obsolete" file  
> which is still in use by a reader, the reader crashes with a Stale  
> NFS Filehandle exception.


You could easily fix this by having the reader create a hard link to the
index file. e.g.

ln foo foo-client.my.org-$$
open("foo-client.my.org-$$");
....
read()
...
close()
rm foo-client.my.org-$$

> Lucene does not currently exploit advisory read-locking at all.  One  
> possible solution to this problem is to have readers secure advisory  
> locks against the files they need, and for index-writing applications  
> to spare files when such locks are detected.  Unfortunately, it is  
> very difficult for library code to enforce the level of discipline  
> needed by fcntl() locks.  flock() would work much better.

Why do read locking at all?

> I read in the manpage for flock(),
> 
>      flock(2) does not lock files over NFS. Use fcntl(2) instead:
>      that does work over NFS, given a sufficiently recent version
>      of Linux and a server which supports locking.
> 
> However, apparently this is no longer accurate as of 2.6.12,  
> according to both the FAQ and this October 2005 post from Trond  
> Myklebust: <http://sourceforge.net/mailarchive/message.php? 
> msg_id=17217586>.
> 
> What I am confused about is how faithful the flock() emulation is.   
> The FAQ states:
> 
>      On local Linux filesystems, POSIX locks and BSD locks are
>      invisible to one another. Thus, due to this emulation,
>      applications running on a Linux NFS server will still see
>      files locked by NFS clients as being locked with a fcntl()/POSIX
>      lock, whether the application on the client is using a BSD-style
>      or a POSIX-style lock. If the server application uses flock()BSD
>      locks, it will not see the locks the NFS clients use.
> 
> This says to me that we must always check for both fcntl and flock  
> locks before zapping a file.  However, I am worried that if an  
> application opens a file and checks for the existence of an fcntl  
> lock, it may force an inappropriate lock release if a lock is held  
> elsewhere within the process.  Is that a possibility?  Or is the flock 
> () emulator applying fcntl() locks against some symbolic stand-in?   
> And if it is locking a stand-in, are there circumstances under which  
> it is outright impossible for an application to figure out whether  
> someone, somewhere has secured a lock against a file on an NFS volume?
> 
> I recognize that even in a best-case scenario, flock() over NFS will  
> only help us with recent systems, which isn't ideal.  Fortunately,  
> the penalty for lock failure is only a crashed searching application,  
> rather than index corruption (Lucene uses a dot-lock mechanism for  
> serializing writer access, which I take should be bulletproof on NFS  
> after kernel 2.6.5 made O_EXCL creates atomic).  However, if an  
> alternative design occurs to you, I'm all ears.
> 
> Lastly, we have been scratching our heads as to how we might detect  
> at index-creation time that the user has specified that the index be  
> located on an NFS volume.  We would like to warn the user in such a  
> case.  A couple hacks have been proposed, but they are decidedly non- 
> portable.  If someone can suggest a algorithm that will determine  
> whether we can count on delete-on-last-close by failing reliably on  
> an NFS volume, we would be grateful.
> 
> Cheers,
> 
> Marvin Humphrey
> Rectangular Research
> http://www.rectangular.com/
> 
> 
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
