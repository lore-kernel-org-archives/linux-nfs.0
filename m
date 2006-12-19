From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC:PATCH] nfs-utils - showmount RPC timeout handling
Date: Tue, 19 Dec 2006 20:42:16 +1100
Message-ID: <17799.46072.741856.446440@cse.unsw.edu.au>
References: <1166499757.3482.40.camel@raven.themaw.net>
	<17799.25999.584498.734073@cse.unsw.edu.au>
	<1166518531.3482.50.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwbTx-0008Nr-1j
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 01:41:57 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GwbTw-00022U-38
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 01:41:58 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: message from Ian Kent on Tuesday December 19
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

On Tuesday December 19, raven@themaw.net wrote:
> > 
> > Isn't this bind a no-op?  When you first write to a socket which is
> > unbound it is automatically bound, so you don't need to pre-bind it.
> 
> Possibly, but personally I like to retain stuff like this for internal
> documentation.
> 
> Do you feel strongly about it?

No.  It just seemed like "that's a lot of new code for relatively
little new functionality, I wonder if it is all needed", and I
discovered some that wasn't.
But if you think it is good to keep it, I'm OK with that.

I'll look forward to your next revision which I'm sure will be
accepted.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
