From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: #255931 NFS fh_verify causes lost output
Date: Fri, 20 Aug 2004 12:30:40 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16677.25168.374531.344188@cse.unsw.edu.au>
References: <20040818210041.A2223@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Paul Szabo <psz@maths.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxzBE-00014q-NE
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 19:31:00 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BxzBD-0005Mc-20
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 19:31:00 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: message from Christoph Hellwig on Wednesday August 18
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday August 18, hch@infradead.org wrote:
> We have the following report from Paul Szabo in the Debian bugtracking system,
> any chance someone could look into it?  The RedHat bugzilla reference is quite
> interesting aswell.
> 
> -----------------------------------------------------------------------------
> Package: kernel
> Version: N/A; reported 2004-06-24
> Severity: important
> Tags: patch
> 
> With default root_squash and subtree_check options, there is a problem with
> NFS exports. The bug may appear also with no_root_squash; can always be
> avoided with no_subtree_check. The bug causes open filehandles to become
> stale, and further read/write access to fail.


Yes... I've seen this reported and seen the suggested patches, but I
haven't been comfortable with the suggestions and have been guilty of
leaving it in the too-hard basket.

I'm tempted to just remove the permission check altogether.

Originally, the check here was "does anyone other that root have x
permission" and "it is exported root_squash".
If the first was "no" and the second was "yes", then access was
denied.
Note that this test does not involve who the current user is, and so
can safely return STALE.

However the first check is not easy to perform when ACLs exist (have I
mentioned that I hate acls?).  So it was changed to the "permission"
check, which seemed close-enough.


Returning EPERM instead of ESTALE seems to fix the symptom, but I
really don't think it is the right thing to do.

So here are my options:

 1/ remove the permission check, and remove a tiny bit of security
    that it is vaguely possible that someone is relying on (if a
    directory is root owned and perm 700, and the fs is exported
    root_squash,subtree_check, then everything below is not
    accessible, even if the right filehandle can be guessed)
 2/ change the error to EPERM, which is wrong because filehandle
    lookup itself shouldn't return EPERM, and if the failure is
    because the file is outside the exported tree rather than inside
    but with wrong permission, then it really should be ESTALE ... but
    who cares what error is returned if someone is guessing
    filehandles, and if they aren't, then they can only get the
    filehandle if they really have access anyway.
 3/ leave it as it is, broken.
 4/ invent some way to test 'does anyone other than root have x
    access'?

As you can see, so far I have leant towards 3.

I suspect 2 is probably best, but I think I'll leave it for now, and
think through it again on Monday and see if I can convince my self of
anything else before I actually submit a patch.

NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
