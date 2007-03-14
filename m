From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Thu, 15 Mar 2007 09:47:35 +1100
Message-ID: <17912.31623.829635.980750@notabene.brown>
References: <45E2C1FD.7000506@RedHat.com>
	<17891.52293.103984.465480@notabene.brown>
	<45E43C92.6090805@redhat.com>
	<17894.2913.850879.838771@notabene.brown>
	<45E6FB0B.7000204@redhat.com>
	<17895.41362.382320.934994@notabene.brown>
	<45E8427A.3030806@redhat.com>
	<17910.15196.104675.695016@notabene.brown>
	<45F6CDA5.9020607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRcG3-0007zW-Ir
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 15:47:49 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRcG5-0006TG-Ft
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 15:47:49 -0700
In-Reply-To: message from Peter Staubach on Tuesday March 13
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

On Tuesday March 13, staubach@redhat.com wrote:
> 
> The small update to the patch is to add the line:
> 
>     data.flags |= NFS_MOUNT_SECFLAVOUR;
> 
> after setting data.pseudoflavor to flavor[i].

Thanks... That implies that I don't need the (rather ugly) -1 value to
say "nothing requested".  I can just test this flag and set
data.pseudoflavor to flavor[i] if it isn't set.

Thanks.


> 
> Anyone know why, off hand, the NFS client needs to make two FSINFO calls?
> 

Not me, know...

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
