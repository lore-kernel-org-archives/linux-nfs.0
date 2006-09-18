From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Crash in dec_zone_page_state when nfs_page req is freed
Date: Mon, 18 Sep 2006 16:55:36 -0700
Message-ID: <1158623736.3376.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPSx6-0005Jf-AA
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 16:55:04 -0700
Received: from e35.co.us.ibm.com ([32.97.110.153])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GPSx5-0001Ua-Rx
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 16:55:05 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8INsvHo021612
	for <nfs@lists.sourceforge.net>; Mon, 18 Sep 2006 19:54:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k8INsvnd328584
	for <nfs@lists.sourceforge.net>; Mon, 18 Sep 2006 17:54:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k8INsvql012535
	for <nfs@lists.sourceforge.net>; Mon, 18 Sep 2006 17:54:57 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8INsuuB012516
	for <nfs@lists.sourceforge.net>; Mon, 18 Sep 2006 17:54:56 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

I am seeing a crash in dec_zone_page_state when called from 

static void nfs_cancel_commit_list(struct list_head *head)
{
	struct nfs_page *req;

	while(!list_empty(head)) {
		req = nfs_list_entry(head->next);
		nfs_list_remove_request(req);
		nfs_inode_remove_request(req);
		nfs_clear_page_writeback(req);
		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
	}
}

I see this was somewhat recently added. It appears that
nfs_clear_page_writeback has resulted in the req being freed. We are
running with CONFIG_SLAB_DEBUG on which poisons memory with repeated
0x6b bytes when freed so the subsequent reference to req results in a
bad wb_page pointer.

Is it the expectation that the request will be freed here? If so, should
the dec_zone_page_state call be re-ordered, the wb_page pointer saved
before calling nfs_clear_page_writeback, or wb_count being incremented
and then adding a call to nfs_release_request?

Frank Filz



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
