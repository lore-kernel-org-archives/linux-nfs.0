From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 23:55:27 -0400
Message-ID: <4632C5AF.7080500@redhat.com>
References: <46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org>
	<46321870.7000607@redhat.com> <20070427203444.GA28874@janus>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hhdru-0007Oq-T8
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 20:45:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hhdrx-0006Zb-2f
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 20:45:09 -0700
In-Reply-To: <20070427203444.GA28874@janus>
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

Frank van Maarseveen wrote:

>I'm quite interested in _any_ patch which would allow me to drop
>the locks obtained by NFS clients on a specific export, either by (1)
>"exportfs -uh" or by (2) "echo /some/path > /proc/fs/nfsd/nlm_drop_lock"
>as Neil mentioned.
>  
>
Thanks for commenting on this. Opinions from users who will eventually 
use these interfaces are always valued.

>[snip]
>
>
>I'd prefer (2) "echo /some/path > /proc/fs/nfsd/nlm_drop_lock" because:
>  
>
To convert the first patch of this submitted series from "fsid" to 
"/some/path" is a no-brainer, since we had gone thru several rounds of 
similar changes. However, my questions (it is more of a Neil's question) 
are, if I convert the first patch to do this,

1) then why do we still need the RPC drop-lock call in nfs-util ?
2) what should we do for the 2nd patch ? i.e., how do we communicate 
with the take-over server it is time for its action, by RPC call or by 
"echo /some/path > /proc/fs/nfsd/nlm_set_grace_or_whatever" ?

In general, I feel if we do this "/some/path" approach, we may as well 
simply convert the 2nd patch from "fsid" to "/some/path". Then we would 
finish this long journey.

-- Wendy

>- Tying the -h (drop locks) option to -u (unexport) is too restrictive IMO.
>  For one thing, there's a bug in the linux NFS client locking code (I
>  reported this earlier) which results in locks not being removed from
>  the server. It was not too difficult to reproduce and programs on the
>  client will wait forever due to this. To handle these kind of situations
>  I need (2) on the server.
>
>- (2) may be useful for other NFS server setups: it is inherently more
>  flexible.
>
>- (2) does not depend on nfs-utils. It's simpler.
>
>
>(*) virtual in this case means a UUID or IP based fsid= option and an
>additional IP address on eth0 per export entry, such, that it becomes
>possible to move an export entry + disk partition + local mount to
>different hardware without needing to remount it on all <large number>
>NFS clients.
>
>  
>


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
