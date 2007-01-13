From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: FILE_SYNC slower than UNSTABLE + COMMIT
Date: Sat, 13 Jan 2007 16:43:16 -0500
Message-ID: <76bd70e30701131343l11bf198am99c908db6b11ed4d@mail.gmail.com>
References: <jeirfb4knt.fsf@sonoasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5qel-0003Xh-T3
	for nfs@lists.sourceforge.net; Sat, 13 Jan 2007 13:43:32 -0800
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H5qen-0004Ay-71
	for nfs@lists.sourceforge.net; Sat, 13 Jan 2007 13:43:21 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1045146ugc
	for <nfs@lists.sourceforge.net>; Sat, 13 Jan 2007 13:43:17 -0800 (PST)
To: "Venkatesh K S" <vsharma@sonoasystems.com>
In-Reply-To: <jeirfb4knt.fsf@sonoasystems.com>
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

On 13 Jan 2007 09:56:14 +0530, Venkatesh K S <vsharma@sonoasystems.com> wrote:
> I have 2 different kernel versions and I notice that the way
> the nfs client honors O_SYNC is different.
> In 2.6.12 variant the client issues UNSTABLE followed by
> a COMMIT call.
> In 2.6.16 variant the nfs client issues a FILE_SYNC call.
>
> The FILE_SYNC call turns out to be about 3 times slower
> against our server. Infact a simple write followed by a
> fsync also turns out to be FILE_SYNC calls. The mount
> is not a "sync" mount.
>
>
> Is there a way a to make these calls in 2.6.16 or later release
> UNSTABLE + COMMIT ?
>
> Are FILE_SYNC calls always slower (I wud assume for NVRAM based server
> it may be as fast as UNSTABLE). In which case this fix into a newer
> kernel seems to be biased towards working well with such servers

There are several reasons why using a FILE_SYNC write is preferable.
You might find some discussion of this in the NFS mailing list
archives.

1.  Fewer operations on the wire.  When the network latency is long,
this is a preferrable optimization.  I recall discussing handling only
small (ie less than 2*wsize) writes this way; you should check how
large O_SYNC writes are handled these days.

2.  The client logic is simpler and less CPU intensive.  Clients
really can't guess which write model that a server might prefer, so
they should optimize for their own advantage, not the server's.

3.  Most servers use a write delay tactic to make FILE_SYNC writes
more efficient (in terms of disk writes).  This might make FILE_SYNC
writes slower than UNSTABLE+COMMIT while retaining server disk
subsystem scalability.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
