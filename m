From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Fix a couple of problems that crept into mount
Date: Wed, 21 Mar 2007 10:27:08 +1100
Message-ID: <17920.28108.666187.839265@notabene.brown>
References: <20070320225217.24284.19896.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTnjd-0000v2-RD
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 16:27:22 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HTnje-0007W6-Qc
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 16:27:24 -0700
In-Reply-To: message from Kevin Coffman on Tuesday March 20
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

On Tuesday March 20, kwc@citi.umich.edu wrote:
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> Commit 6facb22402a0bd8cd49be2ed1a0856b24fef42f4 changed the allocation
> of len to no longer get 20 extra bytes.  It needs to get at least one
> extra byte for a null character, otherwise a single extra option such
> as "sec=krb5" is never copied in parse_opt() and is dropped.
> 
> Commit 44a3727a3243e674a1f1fdad5cbbc639aa25d01c added a typo when
> checking the program name.

Thanks Kevin!

Applied.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
