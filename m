From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 00/33] SVC Transport Switch
Date: Thu, 27 Sep 2007 13:55:38 -0400
Message-ID: <20070927175538.GC10113@fieldses.org>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaxaP-0003G4-Or
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 10:55:42 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaxaP-0006Jb-I8
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 10:55:41 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
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

On Wed, Sep 26, 2007 at 11:57:51PM -0500, Tom Tucker wrote:
> The following series implements a pluggable transport switch for
> RPC servers.

Seeing as this seems not to break anything obvious (well, it compiles
anyway), and people seem to agree we'll merge some version of this
eventually, I've added it to for-mm in hopes it'll get included in an
-mm release soon.

I'll take an hour to read through it some time just for fun, but I'm
depending on Neil and others for serious review in this case.  (One
trivial complaint: git's complaining about lines that add trailing
whitespace.  Might want to run scripts/checkpatch.pl, feeling free to
ignore any false positives.)

--b.

> The biggest changes in this latest incarnation
> are as follows:
> 
> - The overall design of the switch has been modified to be more similar
>   to the client side, e.g.
> 	- There is a transport class structure svc_xprt_class, and
> 	- A transport independent structure is manipulated by xprt 
> 	  independent code (svc_xprt)
> 	- Further consolidation of transport independent logic out of 
> 	  transport providers and into transport independent code.
> - Transport independent code has been broken out into a separate file
> - Transport independent functions prevously adorned with _sock_ have
>   had their names changed, e.g. svc_sock_enqueue
> - atomic refcounts have been changed to krefs
> 
> The patchset is large (33 patches). There are some things that I would like to 
> do that I didn't do because the patchset is already big.  For example, normalize 
> the creation of nfsd listening endpoints using writes to the portlist file. 
> 
> I've attempted to organize the patchset such that logical changes are 
> clearly reviewable without too much clutter from functionally empty name
> changes.  This was somewhat awkward since intermediate patches may look 
> ugly/broken/incomplete to some reviewers. This was to avoid losing the
> context of a change while keeping each patch a reasonable size.  For example, 
> making svc_recv transport independent and moving it to the svc_xprt file 
> cannot be done in the same patch without losing the diffs to the svc_recv 
> function.
> 
> This patchset has had limited testing with TCP/UDP. In this case, the tests 
> included connectathon and building the kernel on an NFS mount running on the 
> transport switch. 
> 
> This patchset is against the 2.6.23-rc8 kernel tree.
> 
> -- 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
