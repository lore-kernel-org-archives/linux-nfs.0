From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 18:06:01 -0500
Message-ID: <20070307230601.GX26553@fieldses.org>
References: <20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<17903.16030.26119.464793@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5CK-0001F4-BZ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:05:28 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP5CL-0000ME-1q
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:05:30 -0800
In-Reply-To: <17903.16030.26119.464793@notabene.brown>
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

On Thu, Mar 08, 2007 at 09:37:18AM +1100, Neil Brown wrote:
> On Wednesday March 7, bfields@fieldses.org wrote:
> > While I'm at it Trond and Christoph and others seem to be asking whether
> > we can't make some more fundamental changes, such as:
> > 
> > 	- Maintaining a static in-kernel exports table instead of
> > 	  loading it on demand from mountd, and
> > 
> 
> Don't like that idea at all.  Demand-loading is a good thing.

Depending on why you need it, this may be inconsistent with the nfsv4
pseudofilesystem construction; we need to be able to service readdir on
the pseudofilesystem root, for example, which means knowing at least the
list of paths.

So could you remind me what the uses cases are here?  Who is it that
requires demand loading, and why?

I'll promise to write it all down someplace and then hopefully we won't
have to re-ask the same questions too many times....

> > 	- divorcing the exports namespace completely from any local
> > 	  process namespace, to the extent that you could even just say
> > 	  "I want to export /dev/sda7 as /usr/local/bin" without first 
> > 	  mounting /dev/sda7 someplace.
> 
> I like that even less.  Much much less.  Way way way less.  Yuck.
> 
> Having a private name-space for nfsd and co might be OK, but that is
> the closest I could come to the above suggestion, and even then I'm not
> convinced.  I think private name spaces are a very powerful tool that
> should be used very very carefully.  There is plenty of room for
> confusion of the poor sysadmin if you start doing too much with
> private name spaces.
> 
> If you built a system where every daemon has a private namespace, then
> having one for nfsd would be ok, but it really should be a system wide
> approach to management, not an approach only used by nfsd.

This is Christoph's suggestion, so I'm cc:'ing him.

I can believe that it would be convenient for sysadmin's to be able to
export filesystems at paths other than the paths they're locally mounted
at.  And once you're going to allow that, it seems cleanest just to let
the exports tree be a purely in-kernel thing.  But this also doesn't
seem like a hard requirement to me.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
