From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: i_generation = 0 special casing
Date: Wed, 24 Nov 2004 12:25:04 +0000
Message-ID: <1101299105.15596.22.camel@imp.csi.cam.ac.uk>
References: <20041124094320.GA10206@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041124094320.GA10206@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2004-11-24 at 09:43 +0000, Christoph Hellwig wrote:
> export_iget (and routines based on it such as xfs_vget) check for
> i_generation beeing 0 meaning that every generation is okay.  Where in
> the NFS code is this wildcard needed?

I didn't have anything to do with the i_generation handling in NFS but
at least NTFS takes i_generation beeing 0 meaning that every generation
is ok.  (That is how Windows NTFS does it so we do the same.  It allows
to disable generation checking by setting all i_generations to 0 on a
volume.)

> I had to find out that XFS starts it's i_generation at zero and either
> I have to fix up the i_generation or drop this wildcard if it's not
> actually used.

In NTFS I start i_generation at 1 and when it reaches 0xffff I wrap it
to 1 again, skipping zero.  (On disk it is 16 bits on NTFS.)

Best regards,

        Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer / IRC: #ntfs on irc.freenode.net
WWW: http://linux-ntfs.sf.net/ & http://www-stu.christs.cam.ac.uk/~aia21/

