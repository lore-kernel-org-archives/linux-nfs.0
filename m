From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: NFS server replacement troubles
Date: Tue, 8 Oct 2002 12:27:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021008122745.C27856@redhat.com>
References: <3FF929A3082ED211B9D700A0C9CFDC8801428E23@exchange.bestivr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yxD3-00005W-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 09:27:49 -0700
To: tswaine@prosodiemail.com
In-Reply-To: <3FF929A3082ED211B9D700A0C9CFDC8801428E23@exchange.bestivr.com>; from tswaine@prosodiemail.com on Tue, Oct 08, 2002 at 10:28:52AM -0400
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

On Tue, Oct 08, 2002 at 10:28:52AM -0400, tswaine@prosodiemail.com wrote:
> 	Stock Redhat Linux 6.2
> 	kernel 2.2.14-6.0.1 on i686
> 	partition being exported is Reiser filesystem

That kernel is utterly ancient.  At the very least you should upgrade to the 
newer errata that were released for 6.2 to fix security issues in the kernel 
and userland, but preferably you should just replace the box with one running 
7.3, as 6.2 is pretty much end of life.  Numerous bugs in NFS, reiserfs and 
the core kernel have been fixed since 2.2.14 was released almost 2 years ago.

		-ben


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
