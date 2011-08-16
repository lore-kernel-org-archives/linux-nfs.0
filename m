Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:33176 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab1HPL4I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 07:56:08 -0400
Message-ID: <4E4A5AD5.3040507@itwm.fraunhofer.de>
Date: Tue, 16 Aug 2011 13:56:05 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
CC: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Subject: Re: [PATCH 0/2] 32/64 bit llseek hashes
References: <20110816112536.1808464.7174.stgit@fsdevel3>
In-Reply-To: <20110816112536.1808464.7174.stgit@fsdevel3>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm really sorry for this patch spam :( I just accidentally hit the 
enter key too early here and so patches go into this series, which
weren't supposed to get in here :(

On 08/16/2011 01:25 PM, Bernd Schubert wrote:
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
>    I think Bruce wanted to take it seperately as bug fix. It should be applied
>    before applying the remaining NFS patches, as without it NFSv4 will always
>    fail with the new 64-bit ext4 seek hashes.
> - split "nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)" into two
>    two separate patches as suggested by Bruce, one patch to rename
>    'access' to 'may_flags'. And the remainder of the original patch to set
>    FMODE_32BITHASH/FMODE_64BITHASH flags and to introduce the new
>    NFSD_MAY_64BIT_COOKIE flag
>
> Version 2:
> - use f_mode instead of O_* flags and also in a separate patch
> - introduce EXT4_HTREE_EOF_32BIT and EXT4_HTREE_EOF_64BIT
> - fix SEEK_END in ext4_dir_llseek()
> - set f_mode flags in NFS code as early as possible and introduce a new
>    NFSD_MAY_64BIT_COOKIE flag for that
>
> --
> Bernd Schubert
> Fraunhofer ITWM
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

