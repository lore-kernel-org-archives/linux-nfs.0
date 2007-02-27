From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 07/11] nfs-utils: mount: Fixed -o remount
Date: Tue, 27 Feb 2007 17:19:30 +1100
Message-ID: <17891.52594.937624.974402@notabene.brown>
References: <45E2C208.7020804@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLvhY-0003eF-10
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:20:40 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLvhY-0008OW-Pq
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:20:42 -0800
In-Reply-To: message from Steve Dickson on Monday February 26
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

On Monday February 26, SteveD@redhat.com wrote:
> commit d507c76527acc3415395cd70cc08d02e32dbe181
> Author: Steve Dickson <steved@redhat.com>
> Date:   Sat Feb 24 15:56:54 2007 -0500
> 
>     Stop remounts (i.e. -o remount) from dropping core.

Not quite sure what this has to do with remount, but I can see you
replacing copy_mntent with dup_mntent.
copy_mntent was only just introduced in an earlier change-set.  Could
this change be merged with that so instead of introducing copy_mntent
then changing, we introduce dup_mntent at the start?

Thanks,

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
