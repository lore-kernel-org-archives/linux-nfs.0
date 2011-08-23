Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886Ab1HWV4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 17:56:14 -0400
Date: Tue, 23 Aug 2011 17:56:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu,
        bernd.schubert@fastmail.fm, hch@infradead.org, adilger@whamcloud.com,
        yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/2] 32/64 bit llseek hashes (v3)
Message-ID: <20110823215608.GH25350@fieldses.org>
References: <20110816115404.1810393.47239.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110816115404.1810393.47239.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 16, 2011 at 01:54:04PM +0200, Bernd Schubert wrote:
> With the ext3/ext4 directory index implementation hashes are used to specify
> offsets for llseek(). For compatibility with NFSv2 and 32-bit user space
> on 64-bit systems (kernel space) ext3/ext4 currently only return 32-bit 
> hashes and therefore the probability of hash collisions for larger directories
> is rather high. As recently reported on the NFS mailing list that theoretical
> problem also happens on real systems:
> http://comments.gmane.org/gmane.linux.nfs/40863
> 
> The following series adds two new f_mode flags to tell ext4
> to use 32-bit or 64-bit hash values for llseek() calls.
> These flags can then used by network file systems, such as NFS, to
> request 32-bit or 64-bit offsets (hashes).
> 
> Version 3:
> - remove patch "RFC: Remove check for a 32-bit cookie in nfsd4_readdir()",
>   I think Bruce wanted to take it seperately as bug fix. It should be applied
>   before applying the remaining NFS patches, as without it NFSv4 will always
>   fail with the new 64-bit ext4 seek hashes.

Yes, applied to my for-3.2 branch at
git://linux-nfs.org/~bfields/linux.git.

For the NFS patches:

	Acked-by: J. Bruce Fields <bfields@redhat.com>

OK by me if they go in through ext4 tree, or however's most convenient.

--b.

> - split "nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)" into two
>   two separate patches as suggested by Bruce, one patch to rename 
>   'access' to 'may_flags'. And the remainder of the original patch to set 
>   FMODE_32BITHASH/FMODE_64BITHASH flags and to introduce the new 
>   NFSD_MAY_64BIT_COOKIE flag
> 
> Version 2:
> - use f_mode instead of O_* flags and also in a separate patch
> - introduce EXT4_HTREE_EOF_32BIT and EXT4_HTREE_EOF_64BIT
> - fix SEEK_END in ext4_dir_llseek()
> - set f_mode flags in NFS code as early as possible and introduce a new
>   NFSD_MAY_64BIT_COOKIE flag for that
> 
> --
> Bernd Schubert
> Fraunhofer ITWM
> 
