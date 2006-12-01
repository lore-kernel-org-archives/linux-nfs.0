From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Fri, 01 Dec 2006 10:29:14 -0500
Message-ID: <45704A4A.6000007@poochiereds.net>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqAPP-0005Xg-1s
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 07:34:41 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GqAPO-0003Uq-36
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 07:34:40 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1GqAPB-0007SR-Pb
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 07:34:30 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
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

Jeff Layton wrote:
> We have had a few reports from customers that showmount -a is just plain
> broken.

...

> The following two patches remedy this. They both should only affect the
> case where new_cache is set.
> 
> -- Jeff

It's been a little over a month since I originally posted these patches 
and haven't received much comment though Neil and I have traded some 
emails off list concerning it. I'd like to move the discussion back to 
the mailing list to get a wider audience and see if we can come to some 
sort of resolution.

When we last communicated, he mentioned a scheme whereby we could 
generate the showmount -a info on the fly rather than trying to maintain 
the rmtab. That sounds like a good approach, but I don't see how that 
can work without some changes in how the caches are managed.

Neil, would it be reasonable to commit these patches now to fix the 
immediate problem and then work on the new scheme that synthesizes the 
info out of the kernel caches like you proposed?

-- Jeff

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
