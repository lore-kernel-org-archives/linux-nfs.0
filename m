From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kNFSdv4 - 1 of 10 - idmap bugfixes and cleanup
Date: Thu, 8 Apr 2004 18:39:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408223911.GC18744@fieldses.org>
References: <20040408111135.5397.patches@notabene> <E1BBOBq-0001Qe-9u@notabene.cse.unsw.edu.au> <20040407233608.6414089a.akpm@osdl.org> <20040408192803.GB17909@fieldses.org> <20040408125528.5362c910.akpm@osdl.org> <20040408220555.GB18744@fieldses.org> <20040408153438.41e2c494.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBiB7-0004YY-Se
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 15:39:21 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BBiB7-0003U9-BT
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 15:39:21 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040408153438.41e2c494.akpm@osdl.org>
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

On Thu, Apr 08, 2004 at 03:34:38PM -0700, Andrew Morton wrote:
> What do you want me to do?

Could you just drop the first 4 for now?  Thanks.

> kNFSdv4-1-of-10-idmap-bugfixes-and-cleanup.patch
> nfsd_idmap_mdr_put_fix.patch
> kNFSdv4-2-of-10-better-handling-of-failed-idmap-lookups.patch
> kNFSdv4-3-of-10-complain-if-idmapd-doesnt-have-channel-open.patch

And then I'll just resubmit those through Neil when they're fixed.
Sorry about that.--b.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
