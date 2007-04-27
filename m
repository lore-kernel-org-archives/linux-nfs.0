From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 11:36:16 -0400
Message-ID: <46321870.7000607@redhat.com>
References: <462D79F0.4060800@redhat.com>	<17965.39683.396108.623418@notabene.brown>	<46302C01.2060500@redhat.com>	<17968.15370.88587.653447@notabene.brown>	<46315EED.9020103@redhat.com>	<17969.37229.250000.895316@notabene.brown>	<20070427111513.GA25126@salusa.poochiereds.net>	<17969.61232.323762.29003@notabene.brown>	<20070427134248.GB25126@salusa.poochiereds.net>	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhSpg-0003H1-LI
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:58:04 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhSpi-00051O-44
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:58:07 -0700
In-Reply-To: <20070427154259.GF32278@fieldses.org>
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

J. Bruce Fields wrote:
> On Fri, Apr 27, 2007 at 03:17:10PM +0100, Christoph Hellwig wrote:
>   
>> In fact couldn't this be treated as a reexport with a NFSEXP_ flag
>> meaning drop all locks to avoid creating new interfaces?
>>     
>
> Off hand, I can't see any reason why that wouldn't work.  The code to
> handle it would probably go in fs/nfsd/export.c:svc_export_parse().
>
>   
Sign :( ... folks, we go back to the loop again. That *was* my first 
proposal ...

-- Wendy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
