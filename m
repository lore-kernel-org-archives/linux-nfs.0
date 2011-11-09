Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab1KIO7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 09:59:41 -0500
Message-ID: <4EBA9551.4000404@redhat.com>
Date: Wed, 09 Nov 2011 08:59:29 -0600
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
To: Bernd Schubert <bernd.schubert@fastmail.fm>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, "J. Bruce Fields" <bfields@redhat.com>,
        "Ted Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 0/4] 32/64 bit llseek hashes (v4)
References: <20110817095717.1879649.41075.stgit@fsdevel3> <4E5D6058.8040805@fastmail.fm>
In-Reply-To: <4E5D6058.8040805@fastmail.fm>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/30/11 5:12 PM, Bernd Schubert wrote:
> On 08/17/2011 11:57 AM, Bernd Schubert wrote:
>> With the ext3/ext4 directory index implementation hashes are used to specify
>> offsets for llseek(). For compatibility with NFSv2 and 32-bit user space
>> on 64-bit systems (kernel space) ext3/ext4 currently only return 32-bit
>> hashes and therefore the probability of hash collisions for larger directories
>> is rather high. As recently reported on the NFS mailing list that theoretical
>> problem also happens on real systems:
>> http://comments.gmane.org/gmane.linux.nfs/40863
>>
>> The following series adds two new f_mode flags to tell ext4
>> to use 32-bit or 64-bit hash values for llseek() calls.
>> These flags can then used by network file systems, such as NFS, to
>> request 32-bit or 64-bit offsets (hashes).
>>
>> Version 4
>> - Andreas noticed there was HAVE_IS_COMPAT_TASK instead of
>>    CONFIG_COMPAT in the
>>    "Return 32/64-bit dir name hash according to usage type"
>>    patch
>>
>> Version 3:
>> - remove patch "RFC: Remove check for a 32-bit cookie in nfsd4_readdir()",
>>    I think Bruce wanted to take it seperately as bug fix. It should be applied
>>    before applying the remaining NFS patches, as without it NFSv4 will always
>>    fail with the new 64-bit ext4 seek hashes.
>> - split "nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)" into two
>>    two separate patches as suggested by Bruce, one patch to rename
>>    'access' to 'may_flags'. And the remainder of the original patch to set
>>    FMODE_32BITHASH/FMODE_64BITHASH flags and to introduce the new
>>    NFSD_MAY_64BIT_COOKIE flag
>>
>> Version 2:
>> - use f_mode instead of O_* flags and also in a separate patch
>> - introduce EXT4_HTREE_EOF_32BIT and EXT4_HTREE_EOF_64BIT
>> - fix SEEK_END in ext4_dir_llseek()
>> - set f_mode flags in NFS code as early as possible and introduce a new
>>    NFSD_MAY_64BIT_COOKIE flag for that
>>
> 
> Ted,
> 
> any chance you could take this series or at least ack the ext4 part? Bruce already acked the NFS patches.
> 
> 
>     Acked-by: J. Bruce Fields <bfields@redhat.com>
> 

Ted, what is the status of these patches for ext4 at this point?

-eric

> 
> Thanks,
> Bernd
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

