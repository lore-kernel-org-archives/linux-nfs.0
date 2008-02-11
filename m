From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 038/100] nfsd: Allow AIX client to read dir containing
 mountpoints
Date: Mon, 11 Feb 2008 15:26:02 -0500
Message-ID: <47B0AF5A.5000206@redhat.com>
References: <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umich.edu> <1201303040-7779-35-git-send-email-bfields@citi.umich.edu> <1201303040-7779-36-git-send-email-bfields@citi.umich.edu> <1201303040-7779-37-git-send-email-bfields@citi.umich.edu> <1201303040-7779-38-git-send-email-bfields@citi.umich.!edu> <47ACB69D.60704@redhat.com> <20080208210335.GI6871@fieldses.org> <47ACC8F3.5070706@redhat.com> <20080208214633.GL6871@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Frank Filz <ffilzlnx@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754923AbYBKU0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 15:26:06 -0500
In-Reply-To: <20080208214633.GL6871@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Feb 08, 2008 at 04:26:11PM -0500, Peter Staubach wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Fri, Feb 08, 2008 at 03:07:57PM -0500, Peter Staubach wrote:
>>>       
>>>> Can we go through this explanation one more time, a little more
>>>> slowly, please?  I am not following it.
>>>>
>>>> It is my understanding that FATTR4_RDATTR_ERROR simply says
>>>> to return a magic value to indicate that the requested attributes
>>>> could not be retrieved during a READDIR operation.  It is also
>>>> my understanding that the FATTR4_MOUNTED_ON_FILEID returns either
>>>> the fileid of the entry in the directory or the fileid of the
>>>> directory which is the root of the mount point which is mounted
>>>> on top of the entry in the directory.
>>>>     
>>>>         
>>> No, it's the fileid of the directory underneath (the mounted-on
>>> directory), not of the directory that's mounted on top of it--that would
>>> be just the regular fileid.  Does that clear up the confusion?
>>>
>>>   
>>>       
>> Yes, that helps.  I was misinterpreting the arguments in the call
>> to vfs_getattr() to be the wrong direction.
>>     
>
> Any ideas for cleanup (especially patches) are welcomed.  I'd rather the
> code be easier to read there.
>
>   
>>>>> +	if (d_mountpoint(dentry) &&
>>>>> +	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
>>>>> +	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
>>>>>         
>>>>>           
>>>> These are some odd looking tests.  What is the real intention
>>>> for these tests?  They don't test just for requests with just
>>>> RDATTR_ERROR and MOUNTED_ON_FILEID set.  They will trigger
>>>> whether or not either or neither is set as well.
>>>>     
>>>>         
>>> Right.  The test is meant to fail iff someone requests an attribute
>>> other than those two.  (Note the different rd_bmval[] array indices.)
>>>
>>>   
>>>       
>> So, it doesn't matter whether those options are even set then?
>>     
>
> Right.
>
> Would something like this clarify?:
>
>   

Yes, that is better.  The whole area is somewhat complex, but every
little bit helps.

    Thanx...

       ps

> --b.
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index b0592e7..ac47f45 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1867,6 +1867,15 @@ out_serverfault:
>  	goto out;
>  }
>  
> +static inline int attributes_need_mount(u32 *bmval)
> +{
> +	if (bmval[0] & ~(FATTR4_WORD0_RDATTR_ERROR | FATTR4_WORD0_LEASE_TIME))
> +		return 1;
> +	if (bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID)
> +		return 1;
> +	return 0;
> +}
> +
>  static __be32
>  nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
>  		const char *name, int namlen, __be32 *p, int *buflen)
> @@ -1888,9 +1897,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
>  	 * we will not follow the cross mount and will fill the attribtutes
>  	 * directly from the mountpoint dentry.
>  	 */
> -	if (d_mountpoint(dentry) &&
> -	    (cd->rd_bmval[0] & ~FATTR4_WORD0_RDATTR_ERROR) == 0 &&
> -	    (cd->rd_bmval[1] & ~FATTR4_WORD1_MOUNTED_ON_FILEID) == 0)
> +	if (d_mountpoint(dentry) && !attributes_need_mount(cd->rd_bmval))
>  		ignore_crossmnt = 1;
>  	else if (d_mountpoint(dentry)) {
>  		int err;
>   

