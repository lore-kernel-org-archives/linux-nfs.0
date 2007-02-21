From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.13.4 - "lockd: weird return 1 for CANCEL call"
Date: Wed, 21 Feb 2007 22:24:49 +1100
Message-ID: <17884.11265.145106.290158@notabene.brown>
References: <9a8748490702210246j38a1ca4bi8de371ba6829ada9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Jesper Juhl" <jesper.juhl@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJpbO-0006J7-Dd
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 03:26:05 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJpbP-0005fB-2Q
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 03:25:40 -0800
In-Reply-To: message from Jesper Juhl on Wednesday February 21
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

On Wednesday February 21, jesper.juhl@gmail.com wrote:
> Greetings,
> 
> I just got a unusual message from lockd on a webserver running a
> custom compiled 2.6.13.4 (yes it is ancient, I know).
> 
> # uname -a
> Linux webserv.somedomain.example 2.6.13.4 #1 SMP Wed Nov 16 10:03:05
> CET 2005 i686 unknown
> 
> # dmesg | tail -n 3
> do_vfs_lock: VFS is out of sync with lock manager!
> lockd: weird return 1 for CANCEL call
> lockd: weird return 1 for CANCEL call
> 
> The server seems to be running fine, so I'm not really worried, but I
> thought maybe someone would like to know. :-)

Thanks.
Don't be worried.  They are both warning about perfectly acceptable
(though uncommon) behaviour.  These warnings have since been removed.

A process was interrupted while trying to get a lock, so the NFS
client didn't know if it actually had the lock or not.
When the process exited, the tried to cancel the lock just to be on
the safe side and was told that it didn't own any such lock.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
