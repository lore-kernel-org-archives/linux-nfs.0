Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44855 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbbEAN3y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 May 2015 09:29:54 -0400
Date: Fri, 1 May 2015 09:29:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150501132953.GA2583@fieldses.org>
References: <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150501020324.GP889@ZenIV.linux.org.uk>
 <20150501122333.1476c999@notabene.brown>
 <20150501022939.GQ889@ZenIV.linux.org.uk>
 <20150501130826.40721dd0@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150501130826.40721dd0@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > What kind of consistency warranties do callers expect, BTW?  You do realize
> > > > that between iterate_dir() and callbacks an entry might have been removed
> > > > and/or replaced?
> > > 
> > > For READDIR_PLUS, lookup_one_len is called on each name and it requires
> > > i_mutex, so the code currently holds i_mutex over the whole sequence.
> > > This is triggering a deadlock.
> > 
> > Yes, I've seen the context.  However, you are _not_ holding it between
> > actual iterate_dir() and those callbacks, which opens a window when
> > directory might have been changed.
> > 
> > Again, what kind of consistency is expected by callers?  Are they ready to
> > cope with "there's no such entry anymore" or "inumber is nothing like
> > what we'd put in ->ino, since it's no the same object" or "->d_type is
> > completely unrelated to what we'd found, since the damn thing had been
> > removed and created from scratch"?
> 
> Ah, sorry.
> 
> Yes, the callers are prepared for "there's no such entry anymore".
> They don't use d_type, so don't care if it might be meaningless.
> NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cautious
> about ino changing.
> 
> In nfs3xdr, we should probably pass 'ino' to encode_entryplus_baggage() and
> thence to compose_entry_fh() and it should report failure if
> dchild->d_inode->i_ino doesn't match.

Just to make sure I understand the concern..... So it shouldn't really
be a problem if readdir and lookup find different objects for the same
name, the problem is just when we mix attributes from the two objects,
right?  Looks like the v3 code could return an inode number derived from
the readdir and a filehandle from the lookup, which is a problem.  The
v4 code will get everything from the result of the lookup, which should
be OK.

> Simply not returning the extra attributes is perfectly acceptable in NFSv3.

Right, so no big deal anyway.--b.

> So it looks like we are mostly OK here - we don't really need i_mutex to be
> held for very long.
> 
> NeilBrown
> 


