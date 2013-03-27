Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39088 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538Ab3C0Rq1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Mar 2013 13:46:27 -0400
Date: Wed, 27 Mar 2013 13:46:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130327174625.GA27426@fieldses.org>
References: <514F31AF.3080709@gmx.de>
 <20130325220143.GD10887@fieldses.org>
 <20130326144640.GB3353@fieldses.org>
 <5151DEF7.3060003@gmx.de>
 <20130326181717.GA8978@fieldses.org>
 <51532A6A.4040307@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51532A6A.4040307@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 27, 2013 at 06:20:42PM +0100, Toralf Förster wrote:
> On 03/26/2013 07:17 PM, J. Bruce Fields wrote:
> > 
> > Bah, too bad.  That patch was definitely not a fix, so there may be some
> > race here.
> > 
> >> What I get at the host is now :
> >>
> >> 2013-03-26T18:32:17.487+01:00 n22 kernel: ------------[ cut here ]------------
> >> 2013-03-26T18:32:17.487+01:00 n22 kernel: WARNING: at mm/page_alloc.c:2376 __alloc_pages_nodemask+0x262/0x7c0()
> > ...
> >> 2013-03-26T18:32:17.487+01:00 n22 kernel: [<c110f149>] __kmalloc+0x1b9/0x1e0
> >> 2013-03-26T18:32:17.487+01:00 n22 kernel: [<f85835bf>] ? cache_check+0x22f/0x340 [sunrpc]
> >> 2013-03-26T18:32:17.487+01:00 n22 kernel: [<f90a0b1c>] nfs4_acl_new+0x1c/0x30 [nfsd]
> >> 2013-03-26T18:32:17.488+01:00 n22 kernel: [<f9095482>] nfsd4_decode_fattr+0x302/0x6c0 [nfsd]
> > ...
> > 
> > A different bug, but thanks for catching it, I suspect the following is
> > all we need.
> > 
> > --b.
> > 
> > commit 814d9d4f9164c3d778dadd093a54bb55d9a0c576
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Tue Mar 26 14:11:13 2013 -0400
> > 
> >     nfsd4: reject "negative" acl lengths
> >     
> >     Since we only enforce an upper bound, not a lower bound, a "negative"
> >     length can get through here.
> >     
> >     The symptom seen was a warning when we attempt to a kmalloc with an
> >     excessive size.
> >     
> >     Reported-by: Toralf Förster <toralf.foerster@gmx.de>
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 0dc1158..d1dd710 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -264,7 +264,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
> >  		iattr->ia_valid |= ATTR_SIZE;
> >  	}
> >  	if (bmval[0] & FATTR4_WORD0_ACL) {
> > -		int nace;
> > +		u32 nace;
> >  		struct nfs4_ace *ace;
> >  
> >  		READ_BUF(4); len += 4;
> > 
> 
> I applied that patach on top of 3.8.4 and wonders now, whether the
> following is the consequence :
> 
> $ df -m /tmp/forT/victims/
> Filesystem     1M-blocks  Used Available Use% Mounted on
> /dev/sdb3         183851 34907    139599  21% /
> 
> $ sudo ls -lh --color /tmp/forT/victims/f062
> ---xr-S--T 2 tfoerste users 985G Mar 27 18:15 /tmp/forT/victims/f062
> 
> ls shows a 1 TB file within a partition where just 34 MB are used at all
> (its only one partition in that system and a separate small /boot too).

It's completely normal for a large file to only take up a small amount
of space, if the file is sparse.  Is that what you're asking about?

Otherwise, are you seeing any problems or any backtraces in the logs?

--b.
