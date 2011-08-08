Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53830 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab1HHPrX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 11:47:23 -0400
Message-ID: <4E400509.8090804@itwm.fraunhofer.de>
Date: Mon, 08 Aug 2011 17:47:21 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
CC: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Subject: Re: [PATCH 0/4] 32/64 bit llseek hashes v2
References: <20110808153432.1872437.85783.stgit@fsdevel3>
In-Reply-To: <20110808153432.1872437.85783.stgit@fsdevel3>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Oh sorry, I forgot to set the correct subject line in my stg command line :(

On 08/08/2011 05:37 PM, Bernd Schubert wrote:
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

