From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] showmount: try v3 before falling back to v1
Date: Tue, 5 Jan 2010 12:31:19 -0500
Message-ID: <6E89479D-45D6-4C59-9639-7C4B893F2A5E@oracle.com>
References: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Dan McGee <dpmcgee@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56991 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0AERg2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2010 12:36:28 -0500
In-Reply-To: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2010, at 8:34 PM, Dan McGee wrote:

> A lot of people don't have anything below v3 enabled, so showmount is
> completely unusable. Try v3 {tcp, udp} first; if they don't work,  
> fall back
> to v1 {tcp, udp}; if those don't work then just fail as before.

I don't see any immediate problems with this.

It might be nice to add a command line option to select which  
transport to use, but that's entirely optional.

> Signed-off-by: Dan McGee <dpmcgee@gmail.com>
> ---
>
> First (and quick) attempt at a patch here for showmount. Let me know  
> if you see
> serious problems with it or the approach. It seemed relatively sane  
> to me and
> fixed my problems after brief testing.
>
> See a report like this for some proof this is an issue in the wild:
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=557954
>
> Thanks,
>
> -Dan
>
> utils/showmount/showmount.c |    8 ++++++++
> 1 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
> index 418e8b9..716c06d 100644
> --- a/utils/showmount/showmount.c
> +++ b/utils/showmount/showmount.c
> @@ -96,6 +96,14 @@ static CLIENT *nfs_get_mount_client(const char  
> *hostname)
> 	rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
> 	CLIENT *client;
>
> +	client = clnt_create(hostname, program, MOUNTVERS_NFSV3, "tcp");
> +	if (client)
> +		return client;
> +
> +	client = clnt_create(hostname, program, MOUNTVERS_NFSV3, "udp");
> +	if (client)
> +		return client;
> +
> 	client = clnt_create(hostname, program, MOUNTVERS, "tcp");
> 	if (client)
> 		return client;
> -- 
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




