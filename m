From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Tue, 24 Apr 2007 18:17:08 +0100
Message-ID: <20070424171708.GA7936@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
	<20070424161027.GA30213@infradead.org>
	<462E38B9.5020808@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@Oracle.com>, anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgOdl-0006bS-35
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 10:17:21 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HgOdm-0002Sg-E5
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 10:17:23 -0700
In-Reply-To: <462E38B9.5020808@RedHat.com>
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

On Tue, Apr 24, 2007 at 01:04:57PM -0400, Steve Dickson wrote:
> >Although not the fastes approach the only long-term viable one
> >would be to update the glibc rpc code for the new TIRPC APIs and
> >IPv6 support.  Even if it's unclear whether Uli would actually
> >include it that gives a better start to avoid all kinds of security
> >or useability-related regressions.
> Well I have a strong hunch that the glibc people do not want anything
> to do with changing *any* of the RPC code.

That's the impression I got, yes.

> I know for a fact that they
> are very sorry the accepted in the first place... so with
> that type of motivation I really think it would be very painful
> to sell them on take any patches... at all...
> 
> Secondly, having the to debug and fix a small part of the
> RPC code in glibc, I have experienced how truly difficult
> it is work with such a large beast... so I pretty confident
> that breaking out the RPC into a library we can maintain
> ourselves is a good direction to move...

Well, even with a separate library it's probably better to
start out with the glibc code to bug to bug compatible.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
