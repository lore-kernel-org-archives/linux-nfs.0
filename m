From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 16:54:06 -0500
Message-ID: <20070307215406.GR26553@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP44n-0001lp-5y
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:53:37 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP44j-0008Vh-OD
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:53:36 -0800
In-Reply-To: <EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
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

On Wed, Mar 07, 2007 at 04:23:23PM -0500, Talpey, Thomas wrote:
> At 04:17 PM 3/7/2007, J. Bruce Fields wrote:
> >There's an expiry time that's passed down with each cache entry.  In
> >this particular case it's 30 minutes.  There's also a "flush" file you
> >can write to to ask that the whole cache be flushed.  I don't remember
> >how this works in detail, though.
> 
> Aha - so the time comes from mountd. There's some sort of refresh
> timer that the kernel triggers though. So it's not a deadline of this
> time (I think). Or is it.

The kernel sweeps through the cache every now and then and cleans out
expired entries.  I think it also takes note of the earliest future
expiry it runs across in the process, and uses that to decide when to
check next.  This is all in linux/net/sunrpc/cache.c:cache_clean().

> The "flush" file lives in /proc/net/rpc/nfsd.export, and you write an
> integer value to it. I *think* it then flushes any entries which are
> more than that many seconds old.

Right.

> The whole thing makes my head hurt and I try not to look at it.

Well, non-head-hurty ideas always welcomed.  I've got two export-related
problems to fix:

	- Our current NFSv4 pseudofs fsid=0 hack is a pain to administer
	  and results in inconsistent paths across different NFS
	  versions.

	- The trick of using the pseudoflavor as a client name (so doing

		/export	 gss/krb5(rw)
	
	  instead of

		/export *(sec=krb5,rw)

	  ), is inconsistent with what other os's do, and makes it
	  impossible to specify restrictions based both on flavor and on
	  ip network/dns name/netgroup.

While I'm at it Trond and Christoph and others seem to be asking whether
we can't make some more fundamental changes, such as:

	- Maintaining a static in-kernel exports table instead of
	  loading it on demand from mountd, and

	- divorcing the exports namespace completely from any local
	  process namespace, to the extent that you could even just say
	  "I want to export /dev/sda7 as /usr/local/bin" without first 
	  mounting /dev/sda7 someplace.

But I really need a better idea of the requirements on the exports
system.  And some other examples to look at wouldn't hurt either.  (Take
pity on me, Linux is all I know....)

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
