From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 10:11:24 -0400
Message-ID: <42C2AC0C.7090606@redhat.com>
References: <20050628224356.7785.qmail@web30713.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DndLW-0000dS-Ta
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 07:15:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DndLV-0002QH-AG
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 07:15:22 -0700
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20050628224356.7785.qmail@web30713.mail.mud.yahoo.com>
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

Shantanu Goel wrote:

>Hi Trond,
>
>Attached is the long delayed revised version of the
>writeback smoothing patch this time against
>2.6.12-mm2.  I have omitted the commit w/range and
>mmap writeback from this one.  If this one is deemed
>acceptable for inclusion I'll post the other 2 later. 
>The commit w/range really should be restored as it
>makes quite a difference against Solaris NFS servers
>with regular disks.  I observed a difference of 2-3
>MB/s under sustained writes.  It makes no difference
>with the Linux NFS server since it ignores the range.
>

On Solaris, at least with UFS as the underlying file system, the COMMIT
operations are processed by looking through the entire cached page list
or by doing page lookup operations on each individual page.  If the entire
file is specified, ie. len = 0, then the page list is walked.  If a range
is specified, then just the pages within the range are looked up.

Specifying the range can result in significantly less CPU overhead on the
server.  This is why the NFSv3 COMMIT operation has a range which can be
specified...  :-)

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
