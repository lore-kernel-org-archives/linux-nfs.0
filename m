From: Nathan Scott <nathans@sgi.com>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Mon, 8 May 2006 21:37:48 +1000
Message-ID: <20060508213748.A2084950@wobbly.melbourne.sgi.com>
References: <20060505115254.GA13916@sgi.com> <20060508064255.GA8614@infradead.org> <17503.10386.171006.392544@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Greg Banks <gnb@sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17503.10386.171006.392544@cse.unsw.edu.au>; from neilb@suse.de on Mon, May 08, 2006 at 09:16:34PM +1000
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, May 08, 2006 at 09:16:34PM +1000, Neil Brown wrote:
> On Monday May 8, hch@infradead.org wrote:
> > NACK.  As long as we have no HSM support in the tree there's no reason to
> > add this.  From the kernel's point it's just untested and unused code that
> > can break.
> 
> Greg: you seemed to suggest that there was already code in XFS that
> could make use of this.  If that is so: could you point us to it
> please.

The code in question is in fs/xfs/linux-2.6/xfs_iops.c::xfs_vn_setattr,
fs/xfs/xfs_dmapi.h::AT_DELAY_FLAG, and its users in xfs_setattr and
xfs_free_file_space and one or two other spots in XFS.  The DMAPI code
(driver, outside XFS) can be found in the XFS CVS tree on oss.sgi.com.

> Alternately, if this will only be used by future patches, please feel
> free to add this patch to that set, and add

The DMAPI code was released at the same time as XFS, but it seems to
be a spec that is not widely used (unsurprising since not may people
have tape robots doing their bidding) and, perhaps more importantly,
its not viewed as a particularly clean spec by, erm, certain kernel
developers. ;)

cheers.

-- 
Nathan
