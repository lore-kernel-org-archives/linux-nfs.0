From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (More) NFS Performance woes
Date: Thu, 14 Dec 2006 11:03:59 -0500
Message-ID: <20061214160359.GA11876@fieldses.org>
References: <45815427.8070805@nighthawkrad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gut40-00018h-AY
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 08:04:04 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gut3z-0002wj-6c
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 08:04:05 -0800
To: Christopher Smith <csmith@nighthawkrad.net>
In-Reply-To: <45815427.8070805@nighthawkrad.net>
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

On Fri, Dec 15, 2006 at 12:39:51AM +1100, Christopher Smith wrote:
> The first test is copying a single large file of about 700M from the 
> (client) local disk to the NFS mount.
> The second test is untarring a 700M tarfile from the (client) local disk 
> to the NFS mount (~5000 files).
> 
> Test #1 consistently finishes in about 17 seconds, delivering about 40 
> MiB/s.
> Test #2 consistently finishes in about 85 seconds, delivering about 8 MiB/s

That's about 17ms per file?  Each of those 5000 file creations is a
synchronous operation--the server doesn't respond until it's actually
committed the operation to disk.  I don't really know what expected
numbers are for your hardware, but given that for each file we have to
wait for both the initial creation and the final flush of the data to
disk on close, 17ms doesn't sound too far off.

> For reference, untarring the same tarfile locally on the server machine 
> takes 7-8 seconds (about 80 MiB/s).

Locally there's not the same requirement that stuff be committed to disk
before certain operations can complete.  For all I know it could be
performing that entire operation without touching the disk.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
