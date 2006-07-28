From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH] fix NFS mount.nfs options v4
Date: Fri, 28 Jul 2006 14:48:54 -0400
Message-ID: <44CA5C16.4030402@redhat.com>
References: <44CA32CE.9030205@redhat.com> <44CA41FA.5060804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6XKC-0001xX-6m
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 11:44:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6XKB-0007nc-CA
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 11:44:40 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44CA41FA.5060804@redhat.com>
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

Peter Staubach wrote:
> 
> It seems to me that these two "permission denied" messages may be somewhat
> less than completely helpful.  Would it be possible to be a little more
> explicit about why permission was being denied?
> 

Yes possible. I was thinking of not letting the users know which user 
mounted the export, but that is known by mount command anyways. So, yes 
these messages could be more elaborate :)


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
