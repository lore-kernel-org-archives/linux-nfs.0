From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils-1.0.10/linux 2.6.18 bug?  unable to start nfsd;
	nfssvc "Address already in use"
Date: Fri, 17 Nov 2006 16:04:27 +1100
Message-ID: <17757.17115.139507.336303@cse.unsw.edu.au>
References: <20061116193136.43065.qmail@web23314.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkvtw-0004Nd-BD
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 21:04:32 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gkvtw-00089s-9y
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 21:04:33 -0800
To: Ray <whatdoineed2do@yahoo.co.uk>
In-Reply-To: message from Ray on Thursday November 16
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

On Thursday November 16, whatdoineed2do@yahoo.co.uk wrote:
> hi NFS developers
> 
> issue is, using 2.6.18.2 kernel and 1.0.10 nfs utils
> but i am periodically having problems starting nfsd --
> it drops out after sysloging that "nfssvc "Address
> already in use" when there are actually no other nfsd
> instances running

Have you checked to see if port 2049 is in use?

  netstat -na | grep :2049

Most likely something else is using the port. 
lsof might help you find which process is doing it.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
