From: Romain Dolbeau <romain.dolbeau@caps-entreprise.com>
Subject: Re: Latency problem with some clients but not others
Date: Thu, 16 Aug 2007 09:24:24 +0200
Message-ID: <46C3FBA8.7020905@caps-entreprise.com>
References: <46C33597.3030004@caps-entreprise.com>
	<6E56E676C9D6A74EBC980144BC06A17D04BB45E4@mailbox03.lucas.alllucas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILZia-0008Ba-MR
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 00:24:32 -0700
Received: from gandalf.caps-entreprise.com ([212.180.111.10])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILZid-000504-Fu
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 00:24:37 -0700
Received: from localhost (localhost [127.0.0.1])
	by gandalf.caps-entreprise.com (Postfix) with ESMTP id 1A26916FD5
	for <nfs@lists.sourceforge.net>; Thu, 16 Aug 2007 09:24:26 +0200 (CEST)
Received: from gandalf.caps-entreprise.com ([127.0.0.1])
	by localhost (gandalf [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 16649-06 for <nfs@lists.sourceforge.net>;
	Thu, 16 Aug 2007 09:24:25 +0200 (CEST)
Received: from [172.21.0.9] (bifur.caps-entreprise.com [172.21.0.9])
	by gandalf.caps-entreprise.com (Postfix) with ESMTP id 4783B16E50
	for <nfs@lists.sourceforge.net>; Thu, 16 Aug 2007 09:24:25 +0200 (CEST)
In-Reply-To: <6E56E676C9D6A74EBC980144BC06A17D04BB45E4@mailbox03.lucas.alllucas.com>
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

Eli Stair wrote:

> If I entirely misunderstood your post, and you're having problems with 
> the 8169 systems, not the intel Xeon with e1000, you might want to 
> seriously consider ditching the Realtek (8169) and test with another 
> card in that problematic system.  Easiest and most direct way to test.

I must not have been very clear, because the other anwser
also suggested fo tix the Intel, which works just fine ;-)

The problem seems indeed to be the realtek crap^H^H^Hard,
as replacing it with an old 3com card brought by a colleague,
the problem just go away.

I'll try fiddling with ethtool and if it fails, I'll just
have to buy a bunch of decent PCI cards :-(

Thanks to all for your help,

-- 
Romain Dolbeau
<romain.dolbeau@caps-entreprise.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
