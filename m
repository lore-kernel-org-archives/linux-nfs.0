From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs3 dentry encoding
Date: Thu, 27 May 2004 21:09:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16565.52349.592581.997725@cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
	<E1BPtSE-0004BX-SL@notabene.cse.unsw.edu.au>
	<20040527102049.GI12225@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkXG-0006Qq-4d
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:54 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkXF-0006S0-Nk
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:53 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <okir@suse.de>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Thu, 27 May 2004 21:09:57 +1000
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Thursday May 27
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday May 27, okir@suse.de wrote:
> Hi Neil,
> 
> you recently posted a patch that should fix readdir encoding in
> nfsd. You say there
> 
> 	Note that as the offset and whole response is known to be
> 	4byte-aligned, the offset pointer will never be split over
> 	two pages.
> 
> This is not true. The dirent offset is a 64bit quantity, so it's quite
> possible it will be split across the page boundary. I'm working on a
> patch...

Hmmm, just as well someone is watching over me!  Thanks.
I must have been thinking NFSv2.

I guess we need an offset1 and an offset2 which may not be
consecutive.

I'll look forward to the patch.

NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
