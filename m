From: Philippe Troin <phil@fifi.org>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: 06 Dec 2003 11:50:55 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87n0a5sp28.fsf@ceramic.fifi.org>
References: <20031206044852.26806.qmail@web20021.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASiSA-0007Wt-T6
	for nfs@lists.sourceforge.net; Sat, 06 Dec 2003 11:50:58 -0800
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ASiSA-0006Xz-JU
	for nfs@lists.sourceforge.net; Sat, 06 Dec 2003 11:50:58 -0800
To: Kenny Simpson <theonetruekenny@yahoo.com>
In-Reply-To: <20031206044852.26806.qmail@web20021.mail.yahoo.com>
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

Kenny Simpson <theonetruekenny@yahoo.com> writes:

> I have a up-to-date RH9 (kernel 2.4.20-24.9, nfs utils 1.0.1-3.9) I'm using as
> an NFS client (the server is a NetApp), and I'm trying to use advisory locking
> of a file.
> If the process that locks the file exits normally, the lock is released, and
> everything is fine.
> However, if the process aborts, the lock is left with no clear way to remove
> it.  I must remove the file to get rid of the lock.
> 
> Details:
> Here is a test case:
> int main()
> {
>   int fd = open("file", O_RDWR);
>   if (lockf( fd, F_TLOCK, 0 ) < 0)
> ....  print error message query owner
>   pause();
>   close( fd );
> }
> 
> If I run this, when it gets to the pause(), I can clearly see in /proc/locks
> the process owning the lock.
> If I then kill -ABRT <pid>, the entry in /proc/locks goes away, but the lock is
> not removed from the server.
> When I run the program a second time, the lock acquire failes, and it says the
> (now defunct) old process still owns the lock.  Since I cannot easily make
> another process with the id of the original, I seem to have no way to
> explicitly release the lock.

I've also seen this behavior witht the stock 2.4.22 and 2.4.23
kernels.

See the thread:

 http://sourceforge.net/mailarchive/forum.php?thread_id=3213117&forum_id=4930
 
 
> I even ran ethereal to watch which NLM requests were being made.  No unlock
> request was ever sent, so I don't think this can be a server issue.
> 
> Any ideas?  Is it supposed to work this way?

No and no.

Phil.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
