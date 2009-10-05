From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: [Bug 14276] nfsroot will not remount rw and claims illegal options
Date: Mon, 5 Oct 2009 11:00:42 -0400
Message-ID: <3D734E24-A3B1-4015-B466-4C487255DE57@oracle.com>
References: <bug-14276-104@http.bugzilla.kernel.org/> <200910041748.n94HmwPY005082@demeter.kernel.org> <1254683162.9064.2.camel@heimdal.trondhjem.org> <1254693598.30515.59.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-nfs@vger.kernel.org,
	Hans de Bruin <bruinjm-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:24879 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbZJEPDJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2009 11:03:09 -0400
In-Reply-To: <1254693598.30515.59.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 4, 2009, at 5:59 PM, Trond Myklebust wrote:

> On Sun, 2009-10-04 at 15:06 -0400, Trond Myklebust wrote:
>> Chuck, can you see how the rpc_pton() might be breaking nfsroot?
>> The cmdline is of the form
>>
>>    root=/dev/nfs nfsroot=10.10.0.2:/nfs/gemini,v3,tcp ro  
>> ip=::::::dhcp
>
> I think I see it...
>
> The difference is that rpc_pton4() starts with
>
> 	memset(sap, 0, sizeof(struct sockaddr_in));
>
> That clears the port number that was set in nfs_remount(), and so the
> comparison in nfs_compare_remount_data() fails.
>
> Does the following patch fix the problem?
>
> --------------------------------------------------------------------------
> NFS: Fix port initialisation in nfs_remount()
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> The recent changeset 53a0b9c4c99ab0085a06421f71592722e5b3fd5f (NFS:  
> Replace
> nfs_parse_ip_address() with rpc_pton()) broke nfs_remount, since the  
> call
> to rpc_pton() will zero out the port number in data- 
> >nfs_server.address.
>
> This is actually due to a bug in nfs_remount: it should be looking  
> at the
> port number in nfs_server.port instead...

The analysis sounds correct.  After the options are parsed,  
nfs_server.port is the port number the user specified on the command  
line.  The user-specified value is saved separately because later the  
socket address's port number can be changed via an rpcbind.

In the case of a remount, if the port value isn't changed by the new  
options, the client needs to know what the originally specified value  
was.

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

I don't know if this will address the presenting problem, but yes,  
nfs_remount() is definitely not correct.

> ---
>
> fs/nfs/super.c |    6 ++++--
> 1 files changed, 4 insertions(+), 2 deletions(-)
>
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 0d14704..fb3b280 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1846,9 +1846,10 @@ nfs_compare_remount_data(struct nfs_server  
> *nfss,
> 	    data->acdirmin != nfss->acdirmin / HZ ||
> 	    data->acdirmax != nfss->acdirmax / HZ ||
> 	    data->timeo != (10U * nfss->client->cl_timeout->to_initval /  
> HZ) ||
> +	    data->nfs_server.port != nfss->port ||
> 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
> -	    memcmp(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
> -		   data->nfs_server.addrlen) != 0)
> +	    !rpc_cmp_addr(&data->nfs_server.address,
> +		    &nfss->nfs_client->cl_addr))
> 		return -EINVAL;
>
> 	return 0;
> @@ -1891,6 +1892,7 @@ nfs_remount(struct super_block *sb, int  
> *flags, char *raw_data)
> 	data->acdirmin = nfss->acdirmin / HZ;
> 	data->acdirmax = nfss->acdirmax / HZ;
> 	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
> +	data->nfs_server.port = nfss->port;
> 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
> 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
> 		data->nfs_server.addrlen);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



