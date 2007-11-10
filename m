From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: OOPS in cache_clean
Date: Fri, 9 Nov 2007 19:22:01 -0500
Message-ID: <20071110002201.GO26826@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iqe6o-0002WW-Tb
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 16:21:59 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Iqe6u-0002CY-0m
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 16:22:04 -0800
Received: from bfields by fieldses.org with local (Exim 4.68)
	(envelope-from <bfields@fieldses.org>) id 1Iqe6r-0000jn-6F
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 19:22:01 -0500
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I just ran exportfs -ra on a test machine with 2.6.24-rc2 plus some patches
(current contents of my for-mm branch) recently and got a null dereference in
net/sunrpc/cache.c:cache_clean while it was flushing one of the server rpc
caches.  I stupidly lost the oops message, but not till after I'd convinced
myself that it was in the loop that iterates over a cache bucket:

	for (; ch; cp= & ch->next, ch= *cp) {
		if (current_detail->nextcheck > ch->expiry_time)
			current_detail->nextcheck = ch->expiry_time+1;
		...
	}

Specifically, it was an attempt to access ch->expiry_time when ch was 1.  So
ch->next was 1 for some ch (or the head of a bucket was 1?)

I haven't been able to reproduce it, so I'm just posting here in case somebody
else has seen something similar or has an idea....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
