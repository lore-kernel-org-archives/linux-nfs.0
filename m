From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/4 Revised] NLM failover - nlm_set_igrace
Date: Thu, 29 Mar 2007 00:31:37 -0500
Message-ID: <460B4F39.4000706@redhat.com>
References: <4508DF1A.4090907@redhat.com>
	<17688.30806.252332.646157@cse.unsw.edu.au>
	<4608474D.4030205@redhat.com> <20070328024517.GA15081@fieldses.org>
	<4609FDF8.30005@redhat.com> <20070328232842.GK21221@fieldses.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWm92-0004VX-PW
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 21:21:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWm91-0002th-S1
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 21:21:55 -0700
In-Reply-To: <20070328232842.GK21221@fieldses.org>
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

>On Wed, Mar 28, 2007 at 12:32:40AM -0500, Wendy Cheng wrote:
>  
>
>>These are revised patches based on the discussion we had last September 
>>    
>>
>
>OK.  Would you remind just resending the revised versions of all of them
>whenever they're ready?
>
>It's just that applying patches off a web email archive is a bit of a
>pain (there's all this &amp; stuff to deal with, and who knows what it
>does to the whitespace), while we all have piles of scripts to deal with
>plain emailed patches....
>
>Looks like interesting stuff.
>
>--b.
>  
>
Will do. We have one more patch (user space statd) to finish up - need 
to look into what has been changed in Neil's new nfs-util release. I 
could be his first tester (a scary thought :))..

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
