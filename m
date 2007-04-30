From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Mon, 30 Apr 2007 01:19:38 -0400
Message-ID: <46357C6A.7080007@redhat.com>
References: <46315EED.9020103@redhat.com>	<17969.37229.250000.895316@notabene.brown>	<20070427111513.GA25126@salusa.poochiereds.net>	<17969.61232.323762.29003@notabene.brown>	<20070427134248.GB25126@salusa.poochiereds.net>	<20070427141710.GA11484@infradead.org>	<20070427154259.GF32278@fieldses.org>	<46321870.7000607@redhat.com>	<20070427163129.GI32278@fieldses.org>	<17970.30655.854497.849900@notabene.brown>	<20070429201353.GA23531@fieldses.org>
	<17973.9710.650004.160243@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiO8N-0004mG-HK
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 22:09:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiO8O-0003Fm-LK
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 22:09:14 -0700
In-Reply-To: <17973.9710.650004.160243@notabene.brown>
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

Neil Brown wrote:

>But we probably don't need to go over-board straight away.
>I like the interface:
>   echo -n "flag flag .. /path/name" >  /proc/fs/nfsd/filesystem_settings
>
>where if flags is "?flag", then the value is returned by a subsequent
>read on the same file-descriptor.
>
>  
>
Will do a quick prototype to see whether this would work as good as it 
appears. I haven't given up RPC call (into lockd) either since it seems 
to be a bright idea.

-- Wendy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
