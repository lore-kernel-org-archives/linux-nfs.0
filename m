Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:40767 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613Ab2AJL1V convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 06:27:21 -0500
Subject: Re: [PATCH 0/4] [RESEND] 32/64 bit llseek hashes (v5)
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <20120109132137.2616029.76288.stgit@localhost.localdomain>
Date: Tue, 10 Jan 2012 04:27:15 -0700
Cc: linux-nfs@vger.kernel.org,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        ext4 development <linux-ext4@vger.kernel.org>,
        linux-fsdevel Devel <linux-fsdevel@vger.kernel.org>,
        Fan Yong <yong.fan@whamcloud.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Eric Sandeen <sandeen@redhat.com>
Message-Id: <B5CFE283-4C3A-4C05-A779-05E2BE2EF5C6@whamcloud.com>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
To: "Theodore Ts'o" <tytso@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-01-09, at 6:21 AM, Bernd Schubert wrote:
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

Ted, it would be great if these patches could land.  We hit issues like
this previously as well, which is why we started this patch series in the
first place.

> Version 5
> - update NFSD_MAY_64BIT_COOKIE to 0x1000
> 
> Version 4
> - Andreas noticed there was HAVE_IS_COMPAT_TASK instead of 
>  CONFIG_COMPAT in the 
>  "Return 32/64-bit dir name hash according to usage type"
>  patch
> 
> Version 3:
> - remove patch "RFC: Remove check for a 32-bit cookie in nfsd4_readdir()", 
>  as it was included upstream separately
> - split "nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)" into two
>  two separate patches as suggested by Bruce, one patch to rename 
>  'access' to 'may_flags'. And the remainder of the original patch to set 
>  FMODE_32BITHASH/FMODE_64BITHASH flags and to introduce the new 
>  NFSD_MAY_64BIT_COOKIE flag
> 
> Version 2:
> - use f_mode instead of O_* flags and also in a separate patch
> - introduce EXT4_HTREE_EOF_32BIT and EXT4_HTREE_EOF_64BIT
> - fix SEEK_END in ext4_dir_llseek()
> - set f_mode flags in NFS code as early as possible and introduce a new
>  NFSD_MAY_64BIT_COOKIE flag for that
> 
> --
> Bernd Schubert
> Fraunhofer ITWM
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Engineer                   http://www.whamcloud.com/




