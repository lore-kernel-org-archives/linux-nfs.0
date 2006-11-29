From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Do not leak memory in is_mountpoint()
Date: Wed, 29 Nov 2006 13:13:44 +0100
Message-ID: <20061129121344.GC18149@suse.de>
References: <20061129115103.GB18149@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfbrown@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpOK6-00078X-0K
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 04:13:58 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GpOK4-0005da-NA
	for nfs@lists.sourceforge.net; Wed, 29 Nov 2006 04:13:59 -0800
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id CB4E5215E2
	for <nfs@lists.sourceforge.net>; Wed, 29 Nov 2006 13:13:44 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061129115103.GB18149@suse.de>
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

On Wed, Nov 29, 2006 at 12:51:03PM +0100, Olaf Kirch wrote:
> Not sure if this was discussed before. Anyway, I
> stumbled across this today.

Okay, sorry for the noise. I was looking at old source.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
