From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Wed, 13 Aug 2003 14:06:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16185.47443.33945.603458@gargle.gargle.HOWL>
References: <20030812152154.GQ24349@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Jordi Mallach <jordi@debian.org>,
    203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19mmv9-0000MO-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Aug 2003 21:07:35 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>)
	(for <jordi@debian.org>) (for <203918-quiet@bugs.debian.org>) By note
	With Smtp ; Wed, 13 Aug 2003 14:07:16 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Tuesday August 12
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

On Tuesday August 12, chip@pobox.com wrote:
> HEY NEIL.  HEY EVERYBODY ELSE TOO.
> 
> Could you please give me some reply to this issue?  The beginning of
> the bug report looks boring but it's actually weird.  To me anyway.  :-/
> 

There are two issues here which are possibly quite separate.

The first is the "Call to statd from non-local host".
Given that the in-kernel lockd *always* uses 127.0.0.1 to talk to
statd, this request cannot have come from there.  
So it must have come from elsewhere.
Finding out where would not be easy.
You would want to modify statd so that it reports the source port
number as well as ip address, and then doesn't send a reply (so the
source will keep waiting).
Then cause the problem to re-appear and use lsof to hunt around and
find who has the offending port open.

I don't suppose there is any chance that a user-space nfsd is running
as well as the kernel one?

The second problem relates to the filesystem not being unmountable.
This could be the bug that Mark Hemmet recently reported.  Look for
the subject:
   "lockd fails to purge blocked NLM_LOCKs"

in the archives of this list.  Or it could be some simlar bug that
hasn't yet been found.
Without a "how-to-reproduce" it is hard to know.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
