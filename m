From: Shivaji Navale <shivaji@ee.iitb.ac.in>
Subject: Re: Mailbox corruption on The NFS server
Date: Wed, 3 Dec 2003 16:26:37 +0530 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.44.0312031619030.20659-100000@bhairav.ee.iitb.ac.in>
References: <shs65gzvwr1.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARUgd-0007lB-I5
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 02:56:51 -0800
Received: from [203.199.51.149] (helo=smtp1.iitb.ac.in)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1ARUgc-0001P7-O5
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 02:56:51 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs65gzvwr1.fsf@guts.uio.no>
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


On 2 Dec 2003, Trond Myklebust wrote:

> >>>>> " " == Juri Haberland <list-linux.nfs@spoiled.org> writes:
>
>      > It's considered a bad idea to put mailboxes on a NFS share as
>      > there might be locking issues if two applications simultanously
>      > acces the same mailbox. Either use the maildir format or don't
>      > export your mailboxes via NFS.
>
> Sort of. It can be made to work *provided* that you can guarantee that
> your mail programs all agree to support the same file locking scheme.
> Currently that means they must chose one (or both) of the following
> schemes:
>
>   - fcntl() (a.k.a. POSIX, a.k.a. lockf()) locking
>
>   - dotlocking (a.k.a. creating a lock file using something like 'ln
>     mailbox .mailbox.locked')
>
> Note that the BSD flock() and use of O_EXCL in a dotlocking scheme are
> not considered to be reliable within Linux NFS.

We use sendmail as our MTA and  pine for mails, the dotlocking feature is
there with pine. And it appears  sendmail on invoking procmail waits for
this lock to be released, if it exists.

Is there a way out of this, or rather not have mailboxes exported to
clients.

thanks,
shivaji...

PS:sorry, for starting new thread from an old one.




>
> Cheers,
>   Trond
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> Does SourceForge.net help you be more productive?  Does it
> help you create better code?  SHARE THE LOVE, and help us help
> YOU!  Click Here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
