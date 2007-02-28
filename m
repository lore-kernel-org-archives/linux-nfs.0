From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.11 still seems broken
Date: Thu, 1 Mar 2007 09:54:01 +1100
Message-ID: <17894.2057.828174.464967@notabene.brown>
References: <20070228104726.GA6866@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMXhX-0006W1-3V
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 14:55:11 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMXhX-0002Mz-V0
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 14:55:13 -0800
In-Reply-To: message from Steinar H. Gunderson on Wednesday February 28
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

On Wednesday February 28, sgunderson@bigfoot.com wrote:
> Hi,
> 
> It looks like nfs-utils 1.0.11 is still broken, only now in completely

Can you try 1.0.12?? 1.0.11 had some silly stuff in it, but I'm not
sure it would cause the problem you are seeing..

An 'strace -s1000' of mountd while the client is trying to mount
might help.

> 
>   Feb 28 11:46:17 moccamaster nfsd[6273]: nfssvc: writting fds to kernel failed: errno 0 (Success)
> 

This message didn't come from 1.0.11 !! The speling error was fixxed.

But you still get this message - a newer kernel gets rid of the
message.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
