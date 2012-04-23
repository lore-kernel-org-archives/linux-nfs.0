Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45198 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753585Ab2DWUwe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:52:34 -0400
Message-ID: <4F95C109.1030401@itwm.fraunhofer.de>
Date: Mon, 23 Apr 2012 22:52:25 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Eric Sandeen <sandeen@redhat.com>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <4F91C15B.6070200@redhat.com> <4F93FED6.6090505@itwm.fraunhofer.de> <4F95BD72.6090200@redhat.com>
In-Reply-To: <4F95BD72.6090200@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2012 10:37 PM, Eric Sandeen wrote:
> On 4/22/12 7:51 AM, Bernd Schubert wrote:
>> On 04/20/2012 10:04 PM, Eric Sandeen wrote:
>>> On 1/9/12 7:21 AM, Bernd Schubert wrote:
>>>> From: Fan Yong <yong.fan@whamcloud.com>
>>>>
>>>> Traditionally ext2/3/4 has returned a 32-bit hash value from llseek()
>>>> to appease NFSv2, which can only handle a 32-bit cookie for seekdir()
>>>> and telldir().  However, this causes problems if there are 32-bit hash
>>>> collisions, since the NFSv2 server can get stuck resending the same
>>>> entries from the directory repeatedly.
>>>>
>>>> Allow ext4 to return a full 64-bit hash (both major and minor) for
>>>> telldir to decrease the chance of hash collisions.  This still needs
>>>> integration on the NFS side.
>>>>
>>>> Patch-updated-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
>>>> (blame me if something is not correct)
>>>
>>> Bernd, I've merged this to ext3.  Bruce thought maybe you were working
>>> on the same.  Should I send mine?
>>
>> That is perfectly fine with me.
>>
>>>
>>> Also...
>>>
>>>> +/*
>>>> + * ext4_dir_llseek() based on generic_file_llseek() to handle both
>>>> + * non-htree and htree directories, where the "offset" is in terms
>>>> + * of the filename hash value instead of the byte offset.
>>>> + *
>>>> + * NOTE: offsets obtained *before* ext4_set_inode_flag(dir, EXT4_INODE_INDEX)
>>>> + *       will be invalid once the directory was converted into a dx directory
>>>> + */
>>>> +loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
>>>
>>> ext4_llseek() worries about max offset for direct/indirect vs. extent-mapped
>>> files.  Do we need to worry about the same thing in this function?
>>
>> Hrmm, I just checked it and I think either is wrong. We only have to
>> care about non-dx directories, so ext4_readdir() applies, which limits
>> filp->f_pos < inode->i_size.
>> Going to send a patch tomorrow. Thanks for spotting this!
> 
> The other thing I'm wondering is whether, in light of
> 
> ef3d0fd27e90f67e35da516dafc1482c82939a60 vfs: do (nearly) lockless generic_file_llseek
> 
> taking the i_mutex in ext4_dir_llseek could be a perf regression vs what was there before?  Is there anything about the new function which requires stronger locking?
> 
> I may be missing something obvious about the nfs interaction, not sure.
> 

Oh, good point. I was just about to send a small patch, but reading
through the lockless commit will take some time - its already too late
for me for today. Will work on that tomorrow. Thanks again for your review!

Cheers,
Bernd



diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index b867862..3a4988e2 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -363,7 +363,7 @@ loff_t ext4_dir_llseek(struct file *file, loff_t
offset, int origin)
 		goto out_err;

 	if (!dx_dir) {
-		if (offset > inode->i_sb->s_maxbytes)
+		if (offset > i_size_read(inode))
 			goto out_err;
 	} else if (offset > ext4_get_htree_eof(file))
 		goto out_err;


