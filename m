From: tswaine@prosodiemail.com
Subject: RE: NFS server replacement troubles
Date: Tue, 8 Oct 2002 13:10:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF929A3082ED211B9D700A0C9CFDC8801428E2E@exchange.bestivr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from exchange.bestivr.com ([65.217.47.130] helo=kenny.bestivr.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yxsC-0007RZ-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 10:10:20 -0700
To: bcrl@redhat.com
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Thanks for your reply, but I have to use 6.2 with that
kernel for my specific application. It short it seems the
system works till I replace the hostname/machine. Also the
clients are a mix of Redhat 6.2/7.2 with 2.2.14-6.0.1/
2.4.9-31 respectively.


-----Original Message-----
From: Benjamin LaHaise [mailto:bcrl@redhat.com]
Sent: Tuesday, October 08, 2002 12:28 PM
To: tswaine@prosodiemail.com
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS server replacement troubles


On Tue, Oct 08, 2002 at 10:28:52AM -0400, tswaine@prosodiemail.com wrote:
> 	Stock Redhat Linux 6.2
> 	kernel 2.2.14-6.0.1 on i686
> 	partition being exported is Reiser filesystem

That kernel is utterly ancient.  At the very least you should upgrade to the

newer errata that were released for 6.2 to fix security issues in the kernel

and userland, but preferably you should just replace the box with one
running 
7.3, as 6.2 is pretty much end of life.  Numerous bugs in NFS, reiserfs and 
the core kernel have been fixed since 2.2.14 was released almost 2 years
ago.

		-ben


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
