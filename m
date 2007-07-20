From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 013 of 20] knfsd: nfsd: factor out code
	from	show_expflags
Date: Fri, 20 Jul 2007 12:21:16 +1000
Message-ID: <18080.7196.844577.295882@notabene.brown>
References: <20070710121949.12548.patches@notabene>
	<1070710022737.13509@suse.de>
	<20070713002933.f15724a7.akpm@linux-foundation.org>
	<20070718230555.GN7111@fieldses.org>
	<18078.44366.961344.428533@notabene.brown>
	<20070719153536.GB23093@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBi7T-0000eL-G2
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 19:21:28 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBi7V-0000af-3l
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 19:21:30 -0700
In-Reply-To: message from J. Bruce Fields on Thursday July 19
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday July 19, bfields@fieldses.org wrote:
> On Thu, Jul 19, 2007 at 10:16:14AM +1000, Neil Brown wrote:
> > On Wednesday July 18, bfields@fieldses.org wrote:
> > > OK, here I'm still confused--what should we be doing instead?
> > 
> > Cast the variable to a type that printf knows about.
> >        seq_printf(m, ",anonuid=%d", (int)anonu);
> > 
> > Or maybe cast it to (long) and use %ld, just in case...
> 
> OK.  In the event that uid_t some day ceases to eventually become an
> int, will the casts help, or will they just suppress useful warnings?

Probably not.  Just leave it as it is.

> 
> > Note the stray 's' in the current patch, after the comma!
> 
> Sharp eyes, thanks!  I'll make a patch.  Uh, any objection if I print
> all those uid's as unsigned while I'm at it?

I wondered about that too.  I think we have completely removed the
fiction that 'nobody' is '-2' rather than '65534' so it should be both
safe and sensible to make them unsigned.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
