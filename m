From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kNFSdv4 - 1 of 10 - idmap bugfixes and cleanup
Date: Thu, 8 Apr 2004 15:28:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408192803.GB17909@fieldses.org>
References: <20040408111135.5397.patches@notabene> <E1BBOBq-0001Qe-9u@notabene.cse.unsw.edu.au> <20040407233608.6414089a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBfC8-0004XS-AZ
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 12:28:12 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BBfC7-0007Ld-Op
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 12:28:11 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040407233608.6414089a.akpm@osdl.org>
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

On Wed, Apr 07, 2004 at 11:36:08PM -0700, Andrew Morton wrote:
> 
> - Cannot idmap_lookup() return in state TASK_UNINTERRUPTIBLE?

I assume you meant TASK_INTERRUPTIBLE.

After the

	set_task_state(current, TASK_INTERRUPTIBLE);

either put_mdr, or idmap_wait (which always calls put_mdr) is called,
and put_mdr does a wake_up.  So I believe this is correct, though I do
wish it was clearer.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
