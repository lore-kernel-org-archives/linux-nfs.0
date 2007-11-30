From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH 14/29] NFS: Set default port for NFSv4,
	with support for AF_INET6
Date: Fri, 30 Nov 2007 14:11:41 -0500
Message-ID: <F9DC080B-C21E-4294-965A-DC17739DCCDC@oracle.com>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
	<20071129194107.4170.56000.stgit@picasso.1015granger.net>
	<1196385761.20292.147.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IyBJY-0006yJ-2S
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:14:16 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IyBJb-0005Q4-Q7
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:14:21 -0800
In-Reply-To: <1196385761.20292.147.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 29, 2007, at 8:22 PM, Trond Myklebust wrote:
> On Thu, 2007-11-29 at 14:41 -0500, Chuck Lever wrote:
>> Move more address family dependencies to a helper function.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/nfs/super.c |   30 ++++++++++++++++++++++++++----
>>  1 files changed, 26 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 6377098..6a9192f 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1570,6 +1570,28 @@ static void nfs4_fill_super(struct  
>> super_block *sb)
>>  }
>>
>>  /*
>> + * If the user didn't specify a port, set the port number to
>> + * the NFS version 4 default port.
>> + */
>> +static void nfs4_default_port(struct sockaddr_storage *ssp)
>> +{
>> +	switch (ssp->ss_family) {
>> +	case AF_INET: {
>> +		struct sockaddr_in *ap = (struct sockaddr_in *)ssp;
>> +		if (ap->sin_port == 0)
>> +			ap->sin_port = htons(NFS_PORT);
>> +		break;
>> +	}
>> +	case AF_INET6: {
>> +		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)ssp;
>> +		if (ap->sin6_port == 0)
>> +			ap->sin6_port = htons(NFS_PORT);
>> +		break;
>> +	}
>> +	}
>> +}
>> +
>> +/*
>>   * Validate NFSv4 mount options
>>   */
>>  static int nfs4_validate_mount_data(void *options,
>> @@ -1602,12 +1624,12 @@ static int nfs4_validate_mount_data(void  
>> *options,
>>  				   data->host_addr,
>>  				   sizeof(args->nfs_server.address)))
>>  			return -EFAULT;
>> -		if (args->nfs_server.address.sin_port == 0)
>> -			args->nfs_server.address.sin_port = htons(NFS_PORT);
>>  		if (!nfs_verify_server_address((void *)
>>  						&args->nfs_server.address))
>>  			goto out_no_address;
>>
>> +		nfs4_default_port((void *)&args->nfs_server.address);
>                                     ^^^^^^^^ Eeeewwwww

Ah.  Patch 11's description describes why I did this.  Forthcoming.

>> +
>>  		switch (data->auth_flavourlen) {
>>  		case 0:
>>  			args->auth_flavors[0] = RPC_AUTH_UNIX;
>> @@ -1661,12 +1683,12 @@ static int nfs4_validate_mount_data(void  
>> *options,
>>  		if (nfs_parse_mount_options((char *)options, args) == 0)
>>  			return -EINVAL;
>>
>> -		if (args->nfs_server.address.sin_port == 0)
>> -			args->nfs_server.address.sin_port = htons(NFS_PORT);
>>  		if (!nfs_verify_server_address((void *)
>>  						&args->nfs_server.address))
>>  			return -EINVAL;
>>
>> +		nfs4_default_port((void *)&args->nfs_server.address);
>> +
>>  		switch (args->auth_flavor_len) {
>>  		case 0:
>>  			args->auth_flavors[0] = RPC_AUTH_UNIX;
>>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

