From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 006 of 8] knfsd: nfsd4: fslocations data structures
Date: Mon, 2 Oct 2006 14:23:27 -0400
Message-ID: <20061002182327.GB8084@fieldses.org>
References: <20060929130518.23919.patches@notabene>
	<1060929030913.24108@suse.de>
	<20060928234540.fd74f1e1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUSS1-0006BV-87
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:23:37 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUSS1-0007nm-RF
	for nfs@lists.sourceforge.net; Mon, 02 Oct 2006 11:23:38 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060928234540.fd74f1e1.akpm@osdl.org>
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

On Thu, Sep 28, 2006 at 11:45:40PM -0700, Andrew Morton wrote:
> On Fri, 29 Sep 2006 13:09:13 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > 
> > From: Manoj Naik <manoj@almaden.ibm.com>
> > 
> > Define FS locations structures, some functions to manipulate them, and add
> > code to parse FS locations in downcall and add to the exports structure.
...
> > +	if (fsloc->locations_count < 0)
> 
> this is unsigned.

Yes, thanks.

> > +	fsloc->locations = kzalloc(fsloc->locations_count
> > +			* sizeof(struct nfsd4_fs_location), GFP_KERNEL);
> 
> This is subject to multiplication overflow.  If it's a privileged operation
> and isn't dependent on stuff coming in over the wire then ok..

This is data provided locally by root.  But there's no reason to allow
this to be arbitrarily large, and I'd still prefer to have some
sanity-checking, so I'll replace the bogus "<0" check above by a
check for something "too large".

> > +out_free_all:
> > +	nfsd4_fslocs_free(fsloc);
> 
> This call to nfsd4_fslocs_free() can end up kfreeing members of
> fsloc->locations[] which haven't been initialised here.  Are we sure the
> caller set them all to zero?

Yes.  There will only ever be one caller, and it has to initialize
these to zero.  I agree that this could be more obvious....

> > +	return err;
> > +}
> > +
> > +#else /* CONFIG_NFSD_V4 */
> > +static int fsloc_parse(char **, char *, struct svc_export *) { return 0; }
> 
> static inline
> 
> This has a different prototype from the other version of fsloc_parse()
> 
> This ain't C++ - function arguments need identifiers as well as types.
> 
> Someone needs to read Documentation/SubmitChecklist..

That would be me, sorry, yes.

Bryce Harrington is also setting up automatic compile-testing for us
with the obvious config options turned on and off, so hopefully that
will help save me from myself....

Patches addressing the above follow.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
