From: Bernd Schubert <bernd.schubert@fastmail.fm>
Subject: Re: [PATCH 0/2] 32/64 bit llseek hashes (v3)
Date: Tue, 30 Aug 2011 23:59:23 +0200
Message-ID: <4E5D5D3B.7010402@fastmail.fm>
References: <20110816115404.1810393.47239.stgit@localhost.localdomain> <20110823215608.GH25350@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
	linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	tytso@mit.edu, hch@infradead.org, adilger@whamcloud.com,
	yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:36033 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab1H3V7Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 17:59:25 -0400
In-Reply-To: <20110823215608.GH25350@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/23/2011 11:56 PM, J. Bruce Fields wrote:
> On Tue, Aug 16, 2011 at 01:54:04PM +0200, Bernd Schubert wrote:
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
>> Version 3:
>> - remove patch "RFC: Remove check for a 32-bit cookie in nfsd4_readdir()",
>>    I think Bruce wanted to take it seperately as bug fix. It should be applied
>>    before applying the remaining NFS patches, as without it NFSv4 will always
>>    fail with the new 64-bit ext4 seek hashes.
>
> Yes, applied to my for-3.2 branch at
> git://linux-nfs.org/~bfields/linux.git.
>
> For the NFS patches:
>
> 	Acked-by: J. Bruce Fields<bfields@redhat.com>
>
> OK by me if they go in through ext4 tree, or however's most convenient.

Great, thanks!


Cheers,
Bernd
