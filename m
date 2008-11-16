From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] export dir thru 2 diff path names
Date: Sun, 16 Nov 2008 15:04:23 -0500
Message-ID: <20081116200423.GL21551@fieldses.org>
References: <491869F0.1000505@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F374A0@0461-its-exmb02.us.saic.com>
	<491882AB.6070908@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F37542@0461-its-exmb02.us.saic.com>
	<4918859C.6080608@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F3759D@0461-its-exmb02.us.saic.com>
	<20081110192820.GC19053@fieldses.org>
	<ED53D02C-E3A1-4989-904C-CBCB4CCD29EE@oracle.com>
	<20081110204443.GK19053@fieldses.org>
	<620E93B2E5CC3B46BD811165E3335B8702FD3423@0461-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net,
	Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
To: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47804 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbYKPUFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Nov 2008 15:05:52 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1L1nsU-0007hF-4f
	for linux-nfs@vger.kernel.org; Mon, 17 Nov 2008 07:05:50 +1100
In-Reply-To: <620E93B2E5CC3B46BD811165E3335B8702FD3423-9/h0XwadXgnyjpQT3Si/rsM9+qvyE0V4QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 10:04:30AM -0800, Murata, Dennis wrote:
> One last question for the maintainers and the community.  Is this viewed
> as an undocumented feature or a bug to be fixed?

By "this" you mean mountd's current practice of following symlinks in
export points?  If people are using it (and I can't imagine you're the
only ones to try), then I think we should make it a point to keep it
around.  Patches to the documentation (probably the exports man page,
kept in the nfs-utils code) welcomed.

--b.

> I would hate to
> recommend use of the exported link, only to have it disabled by an
> updated patch.
> 
> Wayne 
> 
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> > Sent: Monday, November 10, 2008 2:45 PM
> > To: Chuck Lever
> > Cc: Murata, Dennis; nfs@lists.sourceforge.net; Sev Binello
> > Subject: Re: [NFS] export dir thru 2 diff path names
> > 
> > On Mon, Nov 10, 2008 at 03:20:42PM -0500, Chuck Lever wrote:
> > > On Nov 10, 2008, at Nov 10, 2008, 2:28 PM, J. Bruce Fields wrote:
> > >> On Mon, Nov 10, 2008 at 11:28:04AM -0800, Murata, Dennis wrote:
> > >>> That really is the 64K question.  During my initial testing, I 
> > >>> exported the parent directory.  Now I am explicitly exporting the 
> > >>> installation directories, where I see the exportfs 
> > message.  In the 
> > >>> messages log file on the server the mount request from 
> > the client is 
> > >>> always the actual directory.
> > >>
> > >> I don't see how this would be "unsafe"--if it works, go for it.
> > >>
> > >> One potential trap: it's using the same client list and export 
> > >> options for both, so if you think you can make one of them 
> > read-only 
> > >> and one of them writeable, for example, you'll be disapointed.
> > >
> > > I wonder how this behaves on the client side.  If the same client 
> > > mounts both paths, will it recognize that these are the 
> > same and use a 
> > > shared page cache for both?
> > 
> > Yeah, who knows.  I suspect it assumes they're different if 
> > the mount paths are different.
> > 
> > But for most people's purposes it probably doesn't matter 
> > much.  (For the purposes people have mentioned so far they 
> > don't even need to mount both paths from the same client at once.)
> > 
> > --b.
> > 
> 
> -------------------------------------------------------------------------
> This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
> Build the coolest Linux based applications with Moblin SDK & win great prizes
> Grand prize is a trip for two to an Open Source event anywhere in the world
> http://moblin-contest.org/redirect.php?banner_id=100&url=/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

