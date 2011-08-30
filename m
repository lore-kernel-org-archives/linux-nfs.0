Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:51023 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207Ab1H3WMn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 18:12:43 -0400
Message-ID: <4E5D6058.8040805@fastmail.fm>
Date: Wed, 31 Aug 2011 00:12:40 +0200
From: Bernd Schubert <bernd.schubert@fastmail.fm>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, "J. Bruce Fields" <bfields@redhat.com>,
        "Ted Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 0/4] 32/64 bit llseek hashes (v4)
References: <20110817095717.1879649.41075.stgit@fsdevel3>
In-Reply-To: <20110817095717.1879649.41075.stgit@fsdevel3>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/17/2011 11:57 AM, Bernd Schubert wrote:
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
> Version 4
> - Andreas noticed there was HAVE_IS_COMPAT_TASK instead of
>    CONFIG_COMPAT in the
>    "Return 32/64-bit dir name hash according to usage type"
>    patch
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

Ted,

any chance you could take this series or at least ack the ext4 part? 
Bruce already acked the NFS patches.


	Acked-by: J. Bruce Fields <bfields@redhat.com>



Thanks,
Bernd
