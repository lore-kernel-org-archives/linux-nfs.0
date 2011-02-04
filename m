Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:48396 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794Ab1BDDsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 22:48:09 -0500
Message-ID: <4D4B76F8.8060500@parallels.com>
Date: Thu, 3 Feb 2011 21:48:08 -0600
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Ensure user-supplied string null terminated before kstrdup()
References: <4D4B287E.70206@parallels.com> <1296788385.2957.8.camel@heimdal.trondhjem.org>
In-Reply-To: <1296788385.2957.8.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/03/2011 08:59 PM, Trond Myklebust wrote:
> On Thu, 2011-02-03 at 16:13 -0600, Rob Landley wrote: 
>> From: Rob Landley <rlandley@parallels.com>
>>
>> Make sure user string is null terminated before copying it.
>>
>> Signed-off-by: Rob Landley <rlandley@parallels.com>
>> ---
>>
>>  fs/nfs/super.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index b68c860..0ad1255 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1881,9 +1881,12 @@ static int nfs_validate_mount_data(void *options,
>>  
>>  		if (!(data->flags & NFS_MOUNT_TCP))
>>  			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
>> +		/* Force null termination of data->hostname no matter what
>> +		   user passed in. */
>> +		args->namlen		= data->namlen;
>> +		data->namlen = 0;
>>  		/* N.B. caller will free nfs_server.hostname in all cases */
>>  		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
>> -		args->namlen		= data->namlen;
>>  		args->bsize		= data->bsize;
>>  
>>  		if (data->flags & NFS_MOUNT_SECFLAVOUR)
> 
> The "namlen" mount option bears absolutely no relation to the server
> hostname AFAIK. I can't see how this patch makes sense...

That field is right after the hostname in the struct, therefore if it's
zeroed the data->hostname is guaranteed to be null terminated at the end
of its nominal range.  (A bit subtle, hence the comment.)

This isn't necessarily the proper fix, but I don't see why the user
can't feed in a "data" blob with an arbitrarily long hostname.  This is
user supplied data we're arbitrarily kstrdup()ing without checking it,
right?  (Is there a size limit on the option string?  Does the range
check on userspace pointers prevent it from being right _before_
something we shouldn't read and padding up to it?)

Entirely possible this is benign and irrelevant, and you probably have
to be root to trigger it, but it's the kind of security "huh" I thought
I'd ping the list about rather than assuming my inability to figure out
how to exploit it of the top of my head means there's nothing lurking.

Rob
