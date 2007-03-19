From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Add support for quoted mount options
Date: Tue, 20 Mar 2007 08:59:30 +1100
Message-ID: <17919.1986.197057.221467@notabene.brown>
References: <20070319200240.GI18681@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Karel Zak <kzak@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTPtD-0006HH-TX
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 14:59:40 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTPtE-00030Z-QK
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 14:59:42 -0700
In-Reply-To: message from Karel Zak on Monday March 19
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

On Monday March 19, kzak@redhat.com wrote:
> The patch avoid the collision between commas in security contexts and the
> delimiter between mount options.
> 
> Try:
> 	mount.nfs foo://mnt/bar /mnt/bar -o context=\"aaa,bbb,ccc\",ro

Hmmm..... I'm feeling a bit uncomfortable about this.
Lots of code (well, some at least) relies on 'hasmntopt' which does
simple parsing of the option string looking for commas.  If we allow
commas to be embedded in options, that code can potentially get
confused.

Also, this code does not allow a double-quote to appear in the context
string.  You can have two (or 4 or any even number) but not one.
Could that ever be a problem?

What exactly is this context string anyway?  Current kernels don't
seem to use it at all.  Presumably the code to use it is still in
development?   Is it some sort of security token?  How often would it
have commas?  How often would it have double-quote?  Would it be
possible to use a different character than ',' - maybe ':' ???

If it has to have commas, I would much rather use some other encoding,
e.g.
  \054
  =2c
  %2c
  \c
  :Comma:   :-)

But if we can avoid commas altogether, that would be best.
Can the context string even need to have a space in it?  That would be
rather awkward to put in /etc/fstab etc I think.

NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
