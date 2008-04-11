From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: nfs4_getfacl "Failed getxattr operation" when too many ACLentries
 exist
Date: Fri, 11 Apr 2008 18:26:32 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0804111811270.12362@citi.umich.edu>
References: <47FE8C68.50502@csupomona.edu> <Pine.BSO.4.64.0804101829270.12362@citi.umich.edu>
 <Pine.BSO.4.64.0804101837200.12362@citi.umich.edu> <20080411193320.GC16965@fieldses.org>
 <47FFDB69.8030504@csupomona.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Brian De Wolf <bldewolf@csupomona.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:44879 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578AbYDKW0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 18:26:33 -0400
In-Reply-To: <47FFDB69.8030504@csupomona.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Apr 2008, Brian De Wolf wrote:

> On 04/11/08 12:33, J. Bruce Fields wrote:
> > On Thu, Apr 10, 2008 at 06:41:18PM -0400, david m. richter wrote:
> > > On Thu, 10 Apr 2008, david m. richter wrote:
> > > 
> > > > On Thu, 10 Apr 2008, Brian De Wolf wrote:
> > > > 
> > > > > Recently we've been prototyping serving Solaris ZFS exports via NFSv4
> > > > > to some
> > > > > Linux hosts.  These will some day be exposed to general users, so I've
> > > > > been
> > > > > testing things to see if I can break them.  Anyway, it seems that
> > > > > nfs4_getfacl
> > > > > is only able to read ACLs with up to 208 entries.  nfs4_setfacl is
> > > > > able to
> > > > > insert a 209th entry, but any attempts to view or edit the ACLs after
> > > > > that
> > > > > fail with:
> > > > > 
> > > > > Failed getxattr operation
> > > > > : Input/output error
> > > > > 
> > > > > There are two ways to make the ACLs readable again:
> > > > > 1) Have someone log in to the Solaris box and remove some of the
> > > > > entries
> > > > > 2) Reset the ACLs using nfs4_setfacl -s `some spec`
> > > > > 
> > > > > Has anyone run into this issue before?  Is it fixable?  I didn't reach
> > > > > the
> > > > > same problem locally on the Solaris box, nor on another Solaris box
> > > > > with the
> > > > > same NFS mount, so it looks like it's a problem specific to Linux.
> > > > > Here's the
> > > > > versions of relevant packages on the test box running Gentoo (did I
> > > > > miss
> > > > > any?):
> > > > > Kernel: 2.6.23-gentoo-r8
> > > > > nfs-utils-1.1.0-r1
> > > > > attr-2.4.39
> > > > > nfs4-acl-tools-0.3.2
> > > > 	honestly, this probably stems from some naive, unrevisited <ahem>
> > > > assumptions still lingering nfs4-acl-tools code that need fixing.  at
> > > > the -very- least, nfs4_setfacl could save the original ACL and attempt
> > > > to restore it if the setxattr() call fails.
> > > 	sorry, misread part of your letter the first time around -- it'd be
> > > very bizarre if nfs4_getfacl influenced the ACL in any way, so i suspect
> > > that something's going awry with nfs4_setfacl.  seeing such an arbitrary
> > > limit of 208 or 209 ACEs looks like the tools being dumb.
> > 
> > I haven't looked at this code in a while.  From a quick look.... It
> > appears the kernel limits ACLs to 64K (xdr-encoded).  One ACE has length
> > 
> > 	16 + (length of user/group name rounded up to multiple of 4)
> 
> More or less, yes.  An strace of the ruleset "A::OWNER@:" yields a getxattr
> buffer size of 28 bytes.
> 
> > But to be hitting that limit with 208 entries I think you'd have to have
> > user/group names (including domain) of about 300 characters.
> 
> Unfortunately not.  With 209 lines of "A::OWNER@:", it breaks.  208 lines of
> this makes a getxattr buffer of size 4996.  If I use "A::EVERYONE@:", it ends
> up breaking at 180 lines.  At 179 lines, this requires a buffer of 4988 bytes.
> It looks like there might be a ceiling at 5000 bytes?

	oh good, i was going to ask this very thing :)


> > Anyway, strace'ing nfs4_getfacl/nfs4_setfacl would verify whether the
> > error was coming from the kernel or the tools.
> 
> This is when the attributes list is too long:
> 
> getxattr("hello", "system.nfs4_acl"..., 0x0, 0) = -1 EIO (Input/output error)
> 
> I couldn't find a mention of EIO in the man pages for getxattr(2) or stat(2).

	yup, i had the same thought; the manpages don't have the whole 
story.  glancing through, it looks like there are some ways that NFS could 
end up returning an EIO that'd percolate back through sys_getxattr() ..

	if you would, could you get a tcpdump of both the 
nfs4_setfacl-setting-a-too-long-ACL and the subsequent 
nfs4_getfacl-barfs-up-EIO problems?  please use a snaplen of 0 just to 
make sure the payloads come through.  you can email it to me, if you like.

 
> > I have to ask: how many acl entries do you need?
> 
> We don't plan on using huge ACLs, but it's nice to know they'll work if
> someone tries to use them.  If I could limit the maximum number of ACL entries
> to something smaller, I would have done that instead, but it's not
> configurable.

	<nod> the 64K size limit (linux/limits.h) goes for all individual 
xattrs, so there's some ceiling, but that ceiling should be a long way 
off.  if you can gin up that tcpdump capture, that'd be great.


	thanks,

	d
	.
