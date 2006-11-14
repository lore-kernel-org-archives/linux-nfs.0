From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS mount permission failure
Date: Tue, 14 Nov 2006 15:17:59 -0500
Message-ID: <455A2477.9000306@redhat.com>
References: <9c8209a10611141214i7200b704i7cff00d603857447@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gk4jY-0003FX-Bz
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 12:18:16 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gk4jX-0001Rz-PY
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 12:18:17 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611141214i7200b704i7cff00d603857447@mail.gmail.com>
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

Murali Bashyam wrote:
> Can i export a NFS mountpoint in turn as a NFS filesystem in 
> /etc/exports? When i try to mount that filesystem on a remote client, 
> i get permission denied. Is there a workaround for this?

You can't re-export an NFS mounted file system.

The workaround, otherwise known as solution, is to mount the file system
from the server, not from another NFS client.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
