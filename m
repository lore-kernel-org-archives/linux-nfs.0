Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab1LEOuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 09:50:54 -0500
Message-ID: <4EDCDA47.4010702@RedHat.com>
Date: Mon, 05 Dec 2011 09:50:47 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Dick Streefland <dick@streefland.net>, rnews@altium.nl,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] retry for NFS v3 mounts
References: <37c5.4ed7ba54.3cfb1@altium.nl> <4ED7E678.2050104@RedHat.com>
In-Reply-To: <4ED7E678.2050104@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/01/2011 03:41 PM, Steve Dickson wrote:
> Hello,
> 
> On 12/01/2011 12:33 PM, rnews@altium.nl wrote:
>> > Mounting an NFS v3 volume from a server that is currently down,
>> > immediately fails with a timeout error, instead of retrying:
>> > 
>> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> > index 4032bf3..7ca0b3e 100644
>> > --- a/utils/mount/stropts.c
>> > +++ b/utils/mount/stropts.c
>> > @@ -663,6 +663,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
>> >  		case ECONNREFUSED:
>> >  		case EOPNOTSUPP:
>> >  		case EHOSTUNREACH:
>> > +		case ESPIPE:
>> >  			continue;
>> >  		default:
>> >  			goto out;
>> > @@ -848,6 +849,7 @@ static int nfs_is_permanent_error(int error)
>> >  	case ETIMEDOUT:
>> >  	case ECONNREFUSED:
>> >  	case EHOSTUNREACH:
>> > +	case ESPIPE:
>> >  		return 0;	/* temporary */
>> >  	default:
>> >  		return 1;	/* permanent */
>> > 
> I think the problem is more of nfs_rewrite_pmap_mount_options()
> is not interrupting RPC correctly.... How about something like this:
> 
> Author: Steve Dickson <steved@redhat.com>
> Date:   Thu Dec 1 15:35:18 2011 -0500
> 
>     mount.nfs: Background mounts failing on time out errors.
>     
>     Mounting with the "-o v3,bg,proto=udp" options will
>     fail, instead of trying, when the server is down.
>     The reason being nfs_rewrite_pmap_mount_options()
>     is not interrupting RPC timeouts correctly.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 4032bf3..d52e21a 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -540,6 +540,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options
>                         errno = EOPNOTSUPP;
>                 else if (rpc_createerr.cf_stat == RPC_AUTHERROR)
>                         errno = EACCES;
> +               else if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
> +                       errno = ETIMEDOUT;
>                 else if (rpc_createerr.cf_error.re_errno != 0)
>                         errno = rpc_createerr.cf_error.re_errno;
>                 return 0;
Committed...

steved.
