From: Chris Pascoe <c.pascoe@itee.uq.edu.au>
Subject: Re: XFS for NFS
Date: Sat, 3 Aug 2002 12:18:11 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.44.0208031213360.24488-100000@mango.csee.uq.edu.au>
References: <041e01c23a86$d0f3c320$6701a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gum.csee.uq.edu.au ([130.102.66.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aoUl-0005dC-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 19:18:19 -0700
To: Matt Heaton <admin@0catch.com>
In-Reply-To: <041e01c23a86$d0f3c320$6701a8c0@c1886657a>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi Matt,

On Fri, 2 Aug 2002, Matt Heaton wrote:

> A while the following post was made about XFS and that the problem was
> fixed in the 2.4.19 tree of the kernel. My question is do I have to use
> 2.4.19rc5 on the server or the client or both to fix the problem.  Also
> is the 1.x version of nfs utils for the client or server or both?
>
[cut text about periodic hangs with XFS]

The problem here was server-side, so upgrading your XFS kernel to the
2.4.19 release (now in their CVS tree) should fix this problem.

Regarding the NFS utils, you should be running the latest nfs-utils on
both the client and server if possible.  The version of the nfs-utils does
not have any bearing on whether you see this problem with XFS or not,
though.

Regards,
Chris



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
