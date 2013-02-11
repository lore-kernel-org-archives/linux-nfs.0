Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f170.google.com ([209.85.214.170]:53171 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729Ab3BKWZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2013 17:25:01 -0500
MIME-Version: 1.0
In-Reply-To: <20130211213311.GE8257@dastard>
References: <1360571159-3666-1-git-send-email-linkinjeon@gmail.com>
	<20130211213311.GE8257@dastard>
Date: Tue, 12 Feb 2013 07:24:59 +0900
Message-ID: <CAKYAXd8rPwaxe5wzeJ7RfCkkCV22H2FDHzJb4c_D2Qro4eJhXQ@mail.gmail.com>
Subject: Re: [PATCH] fs: encode_fh: return FILEID_INVALID if invalid fid_type
From: Namjae Jeon <linkinjeon@gmail.com>
To: Dave Chinner <david@fromorbit.com>
Cc: bfields@fieldses.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        chris.mason@fusionio.com, sage@inktank.com, miklos@szeredi.hu,
        konishi.ryusuke@lab.ntt.co.jp, mfasheh@suse.com, jlbec@ejvilplan.org,
        jack@suse.cz, bpm@sgi.com, elder@kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-nilfs@vger.kernel.org, reiserfs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/2/12, Dave Chinner <david@fromorbit.com>:
> On Mon, Feb 11, 2013 at 05:25:58PM +0900, Namjae Jeon wrote:
>> From: Namjae Jeon <namjae.jeon@samsung.com>
>>
>> This patch is a follow up on below patch:
>>
>> [PATCH] exportfs: add FILEID_INVALID to indicate invalid fid_type
>> commit: 216b6cbdcbd86b1db0754d58886b466ae31f5a63
> ....
>> diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
>> index a836118..3391800 100644
>> --- a/fs/xfs/xfs_export.c
>> +++ b/fs/xfs/xfs_export.c
>> @@ -48,7 +48,7 @@ static int xfs_fileid_length(int fileid_type)
>>  	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
>>  		return 6;
>>  	}
>> -	return 255; /* invalid */
>> +	return FILEID_INVALID; /* invalid */
>>  }
>
> I think you can drop the "/* invalid */" comment from there now as
> it is redundant with this change.
Okay, Thanks for review :-)
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
>
