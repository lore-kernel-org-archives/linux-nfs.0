From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/4 Revised] NLM failover - nlm_set_igrace
Date: Wed, 28 Mar 2007 00:32:40 -0500
Message-ID: <4609FDF8.30005@redhat.com>
References: <4508DF1A.4090907@redhat.com>
	<17688.30806.252332.646157@cse.unsw.edu.au>
	<4608474D.4030205@redhat.com> <20070328024517.GA15081@fieldses.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWPgV-0002vD-CQ
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 21:22:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWPgQ-0001Zg-H4
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 21:22:50 -0700
In-Reply-To: <20070328024517.GA15081@fieldses.org>
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

>On Mon, Mar 26, 2007 at 06:21:01PM -0400, Wendy Cheng wrote:
>  
>
>>Revised patch based on 2.6.21-rc4.
>>    
>>
>
>Were there supposed to be 4 patches?  If so, where can I find the full
>series?
>
>--b.
>  
>

These are revised patches based on the discussion we had last September 
(shame on me to put this off for so long).

General description:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00034.html
Patch 4-1 is based on:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00035.html
new patch at:
https://www.redhat.com/archives/cluster-devel/2007-March/msg00218.html
Patch 4-2 is based on:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00036.html
new patch at:
https://www.redhat.com/archives/cluster-devel/2007-March/msg00231.html
patch 4-3 original patch on:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00037.html
For 2.6.21 kernel, this patch is no longer needed.
Patch 4.4 is nfs-utils (user mode) original patch on:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00038.html
New patch: to be followed.

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
