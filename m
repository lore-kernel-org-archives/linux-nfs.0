Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38548 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932349Ab2CFAkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 19:40:07 -0500
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 646C720B30
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 19:40:07 -0500 (EST)
Message-ID: <4F555CE5.7050401@itwm.fraunhofer.de>
Date: Tue, 06 Mar 2012 01:40:05 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Ted Ts'o" <tytso@mit.edu>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <20120305155939.GE21356@thunk.org>
In-Reply-To: <20120305155939.GE21356@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05/2012 04:59 PM, Ted Ts'o wrote:
> On Mon, Jan 09, 2012 at 02:21:48PM +0100, Bernd Schubert wrote:
>> diff --git a/fs/ext4/hash.c b/fs/ext4/hash.c
>> index ac8f168..fa8e491 100644
>> --- a/fs/ext4/hash.c
>> +++ b/fs/ext4/hash.c
>> @@ -200,8 +200,8 @@ int ext4fs_dirhash(const char *name, int len, struct dx_hash_info *hinfo)
>>   		return -1;
>>   	}
>>   	hash = hash&  ~1;
>> -	if (hash == (EXT4_HTREE_EOF<<  1))
>> -		hash = (EXT4_HTREE_EOF-1)<<  1;
>> +	if (hash == (EXT4_HTREE_EOF_32BIT<<  1))
>> +		hash = (EXT4_HTREE_EOF_32BIT - 1)<<  1;
>>   	hinfo->hash = hash;
>>   	hinfo->minor_hash = minor_hash;
>>   	return 0;
>
> Is there a reason why we don't need to avoid the collsion with the
> 64-bit EOF value as well?  i.e., I think we also need to add:
>
> 	if (hash == (EXT4_HTREE_EOF_64BIT<<  1))
> 		hash = (EXT4_HTREE_EOF_64BIT - 1)<<  1;
>
> 		       			       	  - Ted


Thanks for looking into it, really appreciated!

Yeah, you are right, we also should check for 64-bit EOF. But wouldn't 
be something like this be better?

	/* check for hash collision */
	if(is_32bit_api() ) {
		if (hash == (EXT4_HTREE_EOF_32BIT<<  1))
			hash = (EXT4_HTREE_EOF_32BIT - 1)<<  1;
	} else {
		if (hash == (EXT4_HTREE_EOF_64BIT<<  1))
			hash = (EXT4_HTREE_EOF_64BIT - 1)<<  1;
	}



Or am I over engineering?


Thanks,
Bernd


