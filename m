From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] showmount: try v3 before falling back to v1
Date: Tue, 5 Jan 2010 14:23:41 -0500
Message-ID: <3F8F085F-E90B-4568-9BB2-F820A7C71A4D@oracle.com>
References: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com> <6E89479D-45D6-4C59-9639-7C4B893F2A5E@oracle.com> <4B438712.1080101@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Dan McGee <dpmcgee@gmail.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:22395 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab0AETYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2010 14:24:32 -0500
In-Reply-To: <4B438712.1080101-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 5, 2010, at 1:38 PM, Steve Dickson wrote:

> On 01/05/2010 12:31 PM, Chuck Lever wrote:
>>
>> On Jan 4, 2010, at 8:34 PM, Dan McGee wrote:
>>
>>> A lot of people don't have anything below v3 enabled, so showmount  
>>> is
>>> completely unusable. Try v3 {tcp, udp} first; if they don't work,  
>>> fall
>>> back
>>> to v1 {tcp, udp}; if those don't work then just fail as before.
>>
>> I don't see any immediate problems with this.
>>
> Well I do have a bz request that we stop using the lower mount
> version so we can move away from NFSv2 support... so here is
> my version of this patch...
>
> Comments??
>
> steved.
>
>
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Jan 5 13:29:07 2010 -0500
>
>    showmount: Try the highest mount version then fall back to lower  
> ones
>
>    Showmount should try the highest mount version first then fall
>    back to the lower ones when the server returns a  
> RPC_PROGVERSMISMATCH
>    error. The idea being not using the lower mount versions will begin
>    the process of moving away from NFSv2 support.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
> index 418e8b9..17224a6 100644
> --- a/utils/showmount/showmount.c
> +++ b/utils/showmount/showmount.c
> @@ -85,22 +85,29 @@ static const char *nfs_sm_pgmtbl[] = {
> 	NULL,
> };
>
> +static const int mount_vers[] = {

RPC version numbers are rpcvers_t, not int.

The array above this one is called "nfs_sm_pgmtbl"... to be consistent  
with existing code you should name this one "nfs_sm_verstbl".

> +	MOUNTVERS_NFSV3,
> +	MOUNTVERS_POSIX,
> +	MOUNTVERS,
> +};
> +static const int max_vers = (sizeof(mount_vers)/ 
> sizeof(mount_vers[0]));

Array indices are unsigned.

Calling this "max_vers" suggests it's actually a version number, and  
not an index into the version array; that's confusing.

The array above this one has a NULL entry as it's final element.  To  
be consistent with existing code, you should copy that logic for this  
array instead of using a separate "max_vers" variable.

> +
> /*
>  * Generate an RPC client handle connected to the mountd service
>  * at @hostname, or die trying.
>  *
>  * Supports both AF_INET and AF_INET6 server addresses.
>  */
> -static CLIENT *nfs_get_mount_client(const char *hostname)
> +static CLIENT *nfs_get_mount_client(const char *hostname, int vers)

RPC version numbers are rpcvers_t, not int.  At the very least,  
clnt_create(3t) takes an unsigned version number argument.

> {
> 	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
> 	CLIENT *client;
>
> -	client = clnt_create(hostname, program, MOUNTVERS, "tcp");
> +	client = clnt_create(hostname, program, vers, "tcp");
> 	if (client)
> 		return client;
>
> -	client = clnt_create(hostname, program, MOUNTVERS, "udp");
> +	client = clnt_create(hostname, program, vers, "udp");
> 	if (client)
> 		return client;
>
> @@ -122,7 +129,7 @@ int main(int argc, char **argv)
> 	mountlist list;
> 	int i;
> 	int n;
> -	int maxlen;
> +	int maxlen, vers=0;

Array indices are unsigned integers.

Calling this "vers" suggests it's actually a version number, and not  
an index into the version array; that's confusing.

> 	char **dumpv;
>
> 	program_name = argv[0];
> @@ -185,7 +192,8 @@ int main(int argc, char **argv)
> 		break;
> 	}
>
> -	mclient = nfs_get_mount_client(hostname);
> +again:
> +	mclient = nfs_get_mount_client(hostname, mount_vers[vers]);
> 	mclient->cl_auth = authunix_create_default();
> 	total_timeout.tv_sec = TOTAL_TIMEOUT;
> 	total_timeout.tv_usec = 0;
> @@ -197,6 +205,10 @@ int main(int argc, char **argv)
> 			(xdrproc_t) xdr_void, NULL,
> 			(xdrproc_t) xdr_exports, (caddr_t) &exportlist,
> 			total_timeout);
> +		if (clnt_stat == RPC_PROGVERSMISMATCH) {
> +			if (++vers <  max_vers)
> +				goto again;
> +		}

clnt_create(3t) should tell you if the requested version number is  
working; libtirpc's version does a NULLPROC call, for example.  It  
would be simpler to move this check into nfs_get_mount_client(), then  
you wouldn't need the retry loop here.

But nfs_get_mount_client() already doesn't care why the  
clnt_create(3t) call fails, it just retries the creation with  
different parameters if it didn't succeed.  Do we really care enough  
to retry _only_ if the specific RPC version isn't available?  We use  
the same procedure number with the same arguments and the same results  
for all three protocol versions, yes?

> 		if (clnt_stat != RPC_SUCCESS) {
> 			clnt_perror(mclient, "rpc mount export");
> 			clnt_destroy(mclient);
> @@ -232,6 +244,10 @@ int main(int argc, char **argv)
> 		(xdrproc_t) xdr_void, NULL,
> 		(xdrproc_t) xdr_mountlist, (caddr_t) &dumplist,
> 		total_timeout);
> +	if (clnt_stat == RPC_PROGVERSMISMATCH) {
> +		if (++vers <  max_vers)
> +			goto again;
> +	}
> 	if (clnt_stat != RPC_SUCCESS) {
> 		clnt_perror(mclient, "rpc mount dump");
> 		clnt_destroy(mclient);

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




