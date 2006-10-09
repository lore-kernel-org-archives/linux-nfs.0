From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Crash in dec_zone_page_state when nfs_page req is freed
Date: Mon, 09 Oct 2006 11:30:41 -0700
Message-ID: <1160418641.3376.103.camel@dyn9047022153>
References: <1158623736.3376.8.camel@dyn9047022153>
	<1158636275.5896.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GWzrT-00032z-2J
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 11:28:23 -0700
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GWzrS-0004Ho-Md
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 11:28:24 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k99IS8t0008635
	for <nfs@lists.sourceforge.net>; Mon, 9 Oct 2006 14:28:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k99IS7RI529586
	for <nfs@lists.sourceforge.net>; Mon, 9 Oct 2006 12:28:07 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k99IS7Xq014959
	for <nfs@lists.sourceforge.net>; Mon, 9 Oct 2006 12:28:07 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1158636275.5896.14.camel@lade.trondhjem.org>
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

On Mon, 2006-09-18 at 23:24 -0400, Trond Myklebust wrote:
> On Mon, 2006-09-18 at 16:55 -0700, Frank Filz wrote:
> > I am seeing a crash in dec_zone_page_state when called from 
> > 
> > static void nfs_cancel_commit_list(struct list_head *head)
> > {
> > 	struct nfs_page *req;
> > 
> > 	while(!list_empty(head)) {
> > 		req = nfs_list_entry(head->next);
> > 		nfs_list_remove_request(req);
> > 		nfs_inode_remove_request(req);
> > 		nfs_clear_page_writeback(req);
> > 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> > 	}
> > }
> > 
> > I see this was somewhat recently added. It appears that
> > nfs_clear_page_writeback has resulted in the req being freed. We are
> > running with CONFIG_SLAB_DEBUG on which poisons memory with repeated
> > 0x6b bytes when freed so the subsequent reference to req results in a
> > bad wb_page pointer.
> 
> Does the attached patch fix it for you?

I've had a chance to do some testing of this. It turns out that
nfs_inode_remove_request() will set wb_page to NULL, so it looks like
the call to dec_zone_page_state needs to be moved up before
nfs_inode_remove_request(). I'm testing that right now, but I start to
wonder exactly what the dec_zone_page_state is doing in this case, I
know that was a recent addition.

Frank Filz



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
