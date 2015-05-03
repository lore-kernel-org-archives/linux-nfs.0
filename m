Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45784 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbbECAhp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 May 2015 20:37:45 -0400
Date: Sat, 2 May 2015 20:37:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150503003743.GA30574@fieldses.org>
References: <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150501020324.GP889@ZenIV.linux.org.uk>
 <20150501122333.1476c999@notabene.brown>
 <20150501022939.GQ889@ZenIV.linux.org.uk>
 <20150501130826.40721dd0@notabene.brown>
 <20150501132953.GA2583@fieldses.org>
 <20150503091653.35169382@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150503091653.35169382@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 03, 2015 at 09:16:53AM +1000, NeilBrown wrote:
> On Fri, 1 May 2015 09:29:53 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> > > On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > > 
> > > > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > > > What kind of consistency warranties do callers expect, BTW?  You do realize
> > > > > > that between iterate_dir() and callbacks an entry might have been removed
> > > > > > and/or replaced?
> > > > > 
> > > > > For READDIR_PLUS, lookup_one_len is called on each name and it requires
> > > > > i_mutex, so the code currently holds i_mutex over the whole sequence.
> > > > > This is triggering a deadlock.
> > > > 
> > > > Yes, I've seen the context.  However, you are _not_ holding it between
> > > > actual iterate_dir() and those callbacks, which opens a window when
> > > > directory might have been changed.
> > > > 
> > > > Again, what kind of consistency is expected by callers?  Are they ready to
> > > > cope with "there's no such entry anymore" or "inumber is nothing like
> > > > what we'd put in ->ino, since it's no the same object" or "->d_type is
> > > > completely unrelated to what we'd found, since the damn thing had been
> > > > removed and created from scratch"?
> > > 
> > > Ah, sorry.
> > > 
> > > Yes, the callers are prepared for "there's no such entry anymore".
> > > They don't use d_type, so don't care if it might be meaningless.
> > > NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cautious
> > > about ino changing.
> > > 
> > > In nfs3xdr, we should probably pass 'ino' to encode_entryplus_baggage() and
> > > thence to compose_entry_fh() and it should report failure if
> > > dchild->d_inode->i_ino doesn't match.
> > 
> > Just to make sure I understand the concern..... So it shouldn't really
> > be a problem if readdir and lookup find different objects for the same
> > name, the problem is just when we mix attributes from the two objects,
> > right?  Looks like the v3 code could return an inode number derived from
> > the readdir and a filehandle from the lookup, which is a problem.  The
> > v4 code will get everything from the result of the lookup, which should
> > be OK.
> 
> That agrees with my understanding, yes.
> 
> I did wonder for a little while about the possibility of a directory
> containing both 'a' and 'b', and NFSv4 doing the readdir and the stat of 'a',
> and the a "mv a b" happening before the stat of 'b'.
> 
> Then the readdir response will show both 'a' and 'b' referring to the same
> object with a link count of 1.
> 
> I can't quite decide if that is a problem or not.

My understanding is that that's completely normal behavior for lots of
filesystems.

Googling around....  Here's Ted on the question:

	http://yarchive.net/comp/linux/readdir_nonatomicity.html

	In some cases it won't even just get lost, but the old and new
	name can both be returned.  For example, if you assume the use
	of a simple non-tree, linked-list implementation of a directory,
	such can be found in Solaris's ufs, BSD 4.3's FFS, Linux's ext2
	and minix filesystems, and many others, and you have a fully
	tightly packed directory (i.e., no gaps), with the directory
	entry "foo" at the beginning of the file, and readdir() has
	already returned the first "foo" entry when some other
	application renames it "Supercalifragilisticexpialidocious", the
	new name will not fit in the old name's directory location, so
	it will be placed at the end of the directory --- where it will
	be returned by readdir() a second time.

	This is not a bug; the POSIX specification explicitly allows
	this behavior.  If a filename is renamed during a readdir()
	session of a directory, it is undefined where that neither,
	either, or both of the new and old filenames will be returned.

--b.
