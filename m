From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Fwd: [PATCH 0/4 Revised] NLM - lock failover]
Date: Wed, 18 Apr 2007 16:35:04 +0100
Message-ID: <20070418153504.GA3805@infradead.org>
References: <46257E41.4060606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeCBY-0002wf-DF
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:35:13 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HeCBZ-0004Wv-Lu
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:35:11 -0700
In-Reply-To: <46257E41.4060606@redhat.com>
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

On Tue, Apr 17, 2007 at 10:11:13PM -0400, Wendy Cheng wrote:
> However, since this particular NLM patch set is only part of the overall 
> scaffolding code to allow NFS V3 server fail over before NFS V4 is 
> widely adopted and stabilized, I'm wondering whether we should drag 
> ourselves too far for something that will be replaced soon.

I don't think that's a valid argument.  We hack this up because it's
going to be obsolete mid-term never was a really good argument.  And in
this case it's a particularly bad one.  People won't rush to NFSv4 just
because someone declares it stable now.  And if they did we couldn't
simply rip out existing functionality.

So please do it properly.


More comments on the rest of the mail later when I have a little more
time at my hand.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
