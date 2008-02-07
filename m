From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] troubles with nohide -- crossmnt
Date: Thu, 07 Feb 2008 18:13:28 -0500
Message-ID: <1202426008.18376.19.camel@heimdal.trondhjem.org>
References: <20080207213605.GB3034@example.org>
	<20080207164110.374a5ab0@tleilax.poochiereds.net>
	<20080207215251.GC3034@example.org> <47AB885C.9080708@RedHat.com>
	<20080207225256.GC25374@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50510 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763676AbYBGXO3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 18:14:29 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNFwp-0004fG-1t
	for linux-nfs@vger.kernel.org; Fri, 08 Feb 2008 10:14:27 +1100
In-Reply-To: <20080207225256.GC25374@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-02-07 at 17:52 -0500, J. Bruce Fields wrote:
> On Thu, Feb 07, 2008 at 05:38:20PM -0500, Steve Dickson wrote:
> > 
> > 
> > Pascal A. Dupuis wrote:
> > > On Thu, Feb 07, 2008 at 04:41:10PM -0500, Jeff Layton wrote:
> > > 
> > >>> /home/user/archive	192.168.1.10(rw,subtree_check,fsid=0) 
> > >>> /home/user           	192.168.1.10(rw,subtree_check,fsid=0,crossmnt) 
> > >>>
> > >> You shouldn't have 2 exports with the same fsid= option. They
> > >> should be different. I'd suggest giving /home/user fsid=0
> > >> and /home/user/archive fsid=1 (or something else).
> > >>
> > > 
> > > OK. It made the trick. I didn't notice that both exported FS had the
> > > same fsid. Thanks. Maybe this should be included in the FAQS ?
> > We are working on changing things so the fsid=0 is not needed...
> 
> More helpful than a FAQ entry might just be a warning from exportfs or
> mountd or whatever--it shouldn't be hard to check for the above.
> 
> I've added this to the list at:
> 
> 	http://wiki.linux-nfs.org/wiki/index.php/To_do

It might not be a bad idea to also warn if we detect that the user
changes the fsid mapping in /etc/exports. If there are active clients at
the time of the modification, then that will cause trouble for them.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

