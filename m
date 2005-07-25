From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 15:30:31 -0700 (PDT)
Message-ID: <20050725223031.2952.qmail@web33905.mail.mud.yahoo.com>
References: <1122326830.19759.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxBT4-0006Ab-Im
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 15:30:38 -0700
Received: from web33905.mail.mud.yahoo.com ([66.163.178.69])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1DxBT3-0005iq-5Y
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 15:30:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122326830.19759.11.camel@lade.trondhjem.org>
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

--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> Try combining a debugging dump ('echo "1"
> >/proc/sys/sunrpc/nfs_debug')
> with a tcpdump on the client and see what that gives you.

Well, with the debugging enabled, in the syslog messages I get:

NFS: NFSv3 not supported
nfs warning: mount version older than kernel
NFS: mount program didn't pass remote address!

I captured the packets via tcpdump, but how do you suggest I go about
extracting useful information from them?  I haven't done any
on-the-wire protcol examination before.

Also, would you mind answering the questions I had asked earlier,
namely what to make of the versions listed for portmapper and status --
should these be "3" in order for NFSv3 to work, or is NFSv3 expecting
their versions to be just "2" and "1" respectively?  By "version" I am
referring to the output in the "version" column of the rpcinfo output.

Thank you.

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
