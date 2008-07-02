From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: inux-next: Tree for July 1
Date: Wed, 2 Jul 2008 19:14:09 -0400
Message-ID: <85D20D35-C93D-4432-8B05-BDDA53331440@oracle.com>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au> <200807012236.19400.rjw@sisk.pl> <1214959743.10317.3.camel@localhost> <76bd70e30807020734g3db408dcqea2a61622c83004d@mail.gmail.com> <1215018911.9783.1.camel@localhost> <76bd70e30807021043x72f3aa46o8d07f2039d2ed455@mail.gmail.com> <1215025355.7237.8.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1215025355.7237.8.camel@localhost>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 2, 2008, at 3:02 PM, Trond Myklebust wrote:
> On Wed, 2008-07-02 at 13:43 -0400, Chuck Lever wrote:
>> On Wed, Jul 2, 2008 at 1:15 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Wed, 2008-07-02 at 10:34 -0400, Chuck Lever wrote:
>>>> On Tue, Jul 1, 2008 at 8:49 PM, Trond Myklebust
>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>> On Tue, 2008-07-01 at 22:36 +0200, Rafael J. Wysocki wrote:
>>>>>> I can't mount NFS shares with this kernel.  I get something of  
>>>>>> this sort in
>>>>>> dmesg and it seems to be 100% reproducible:
>>>>>>
>>>>>> [  314.058858] RPC: Registered udp transport module.
>>>>>> [  314.058863] RPC: Registered tcp transport module.
>>>>>> [  314.490970] RPC: transport (0) not supported
>>>>>> [  319.246987] __ratelimit: 23 messages suppressed
>>>>>
>>>>> Does this patch fix the problem for you?
>>>>> -----------------------------------------------------------------------------------
>>>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>> NFS: Fix the mount protocol defaults for binary mounts
>>>>>
>>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>> ---
>>>>>
>>>>> fs/nfs/super.c |    1 +
>>>>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>>> index e09b1c2..85fbb98 100644
>>>>> --- a/fs/nfs/super.c
>>>>> +++ b/fs/nfs/super.c
>>>>> @@ -1575,6 +1575,7 @@ static int nfs_validate_mount_data(void  
>>>>> *options,
>>>>>
>>>>>               if (!(data->flags & NFS_MOUNT_TCP))
>>>>>                       args->nfs_server.protocol =  
>>>>> XPRT_TRANSPORT_UDP;
>>>>> +               nfs_set_transport_defaults(args);
>>>>
>>>> nfs_set_transport_defaults() is overkill for the legacy mount path.
>>>> The bug is that the logic here assumes that nfs_server.protocol
>>>> already has the default value of XPRT_TRANSPORT_TCP, but commit
>>>> 8b59ea3c removed that default.  The correct fix is to add
>>>>
>>>>            args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
>>>>
>>>> just before the 'if' statement.  We should fold that into  
>>>> 8b59ea3c to
>>>> preserve bisectability.
>>>
>>> NACK. You still need to set the appropriate retrans and timeo  
>>> defaults.
>>
>> NACK squared [Bruce told me to write this].
>>
>> The only bug involves the transport protocol setting for NFSv2/v3  
>> legacy mounts.
>>
>> The legacy mount command already sets appropriate default values for
>> the timeout fields, and the code in that arm of
>> nfs_validate_mount_options() _unconditionally_ copies the mount
>> command's timeout settings into the nfs_parse_mount_options  
>> structure.
>>
>> This is how it worked before commit 8b59ea3c, and 8b59ea3c doesn't
>> change this behavior.
>
> That's utter nonsense. We _never_ relied on the mount command to set
> defaults for us. I remember all too well debugging old versions of
> am-utils/amd that set the TCP flag and then happily set timeout values
> of 7/10 second. As far as I know, all am-utils versions since then  
> have
> used timeo=0, retrans=0.

Whether or not user space sets the defaults is irrelevant.  My point  
is the broken commit doesn't change the behavior of copying these  
values unconditionally into *data.  It does break the transport  
protocol setting accidentally.

> However, that does illustrate something else:
> nfs_set_transport_defaults() has never been necessary for setting  
> timeo
> and retrans, since the zero case is already covered in
> nfs_init_timeout_values() (which is also where the sanity checks are
> applied).

Fine, then.  You should drop 8b59ea3c (as that is only in your devel  
branch and linux-next, and not upstream yet; and it appears to be  
mostly based on false assumptions) and merge it with what you have  
below.  That would be more bisectable, easier to document, and easier  
to review and demonstrate its correctness.

Also consider breaking this into smaller changes (for similar  
reasons).  Cleaning up nfs_init_timeout_values() and adding the macro  
constants could be a separate patch, for example.

A handful of comments below.

>
>
> ---------------------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 2 Jul 2008 14:43:47 -0400
> NFS: Fix the mount protocol defaults for binary mounts
>
> Move the UDP/TCP default timeo/retrans settings for text mounts to
> nfs_init_timeout_values(), which was were they were always being
> initialised for binary mounts.

Nit: "which was _where_ they were always"

> Ensure we do initialise the transport protocol for the legacy binary  
> mount
> case in nfs_validate_mount_data.

One of the original bugs addressed by 8b59ea3c was that the text-based  
mount transport protocol was not being set properly.  You are cleaning  
that up here as well with the addition of  
nfs_set_mount_transport_protocol().

> Ensure that we sanity check the transport protocol in the legacy  
> binary
> mount case in nfs4_validate_mount_data
>
> Fix up the incorrect values of NFS_DEF_UDP_TIMEO,  
> NFS_DEF_UDP_RETRANS to
> match the nfs manpage documentation.

>
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> fs/nfs/client.c        |   13 +++++++-----
> fs/nfs/super.c         |   53 +++++++++++++++++++++++ 
> +------------------------
> include/linux/nfs_fs.h |    4 ++--
> 3 files changed, 37 insertions(+), 33 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index f2a092c..5ee23e7 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -431,14 +431,14 @@ static void nfs_init_timeout_values(struct  
> rpc_timeout *to, int proto,
> {
> 	to->to_initval = timeo * HZ / 10;
> 	to->to_retries = retrans;
> -	if (!to->to_retries)
> -		to->to_retries = 2;
>
> 	switch (proto) {
> 	case XPRT_TRANSPORT_TCP:
> 	case XPRT_TRANSPORT_RDMA:
> +		if (to->to_retries == 0)
> +			to->to_retries = NFS_DEF_TCP_RETRANS;
> 		if (to->to_initval == 0)
> -			to->to_initval = 60 * HZ;
> +			to->to_initval = NFS_DEF_TCP_TIMEO * HZ / 10;
> 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
> 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
> 		to->to_increment = to->to_initval;
> @@ -450,14 +450,17 @@ static void nfs_init_timeout_values(struct  
> rpc_timeout *to, int proto,
> 		to->to_exponential = 0;
> 		break;
> 	case XPRT_TRANSPORT_UDP:
> -	default:
> +		if (to->to_retries == 0)
> +			to->to_retries = NFS_DEF_UDP_RETRANS;
> 		if (!to->to_initval)
> -			to->to_initval = 11 * HZ / 10;
> +			to->to_initval = NFS_DEF_UDP_TIMEO * HZ / 10;
> 		if (to->to_initval > NFS_MAX_UDP_TIMEOUT)
> 			to->to_initval = NFS_MAX_UDP_TIMEOUT;
> 		to->to_maxval = NFS_MAX_UDP_TIMEOUT;
> 		to->to_exponential = 1;
> 		break;
> +	default:
> +		BUG();

Yes, it's a software bug.  But do you really need to throw an Oops  
here?  Logging a warning seems perfectly adequate.

>
> 	}
> }
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index e09b1c2..47cf83e 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -819,40 +819,39 @@ static void nfs_parse_ip_address(char *string,  
> size_t str_len,
> }
>
> /*
> - * Time-out and mount transport default settings are based on the
> - * specified NFS transport.  For legacy mounts, these are set by
> - * the mount command before mount(2) is invoked.  For text-based
> - * mounts, the kernel must take care to set these.
> + * Sanity check the NFS transport protocol.
> + *
>  */
> -static void nfs_set_transport_defaults(struct nfs_parsed_mount_data  
> *mnt)
> +static void nfs_validate_transport_protocol(struct  
> nfs_parsed_mount_data *mnt)
> {
> 	switch (mnt->nfs_server.protocol) {
> 	case XPRT_TRANSPORT_UDP:
> -		if (mnt->mount_server.protocol == 0)
> -			mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
> -		if (mnt->timeo == 0)
> -			mnt->timeo = NFS_DEF_UDP_TIMEO;
> -		if (mnt->retrans == 0)
> -			mnt->retrans = NFS_DEF_UDP_RETRANS;
> -		break;
> 	case XPRT_TRANSPORT_TCP:
> 	case XPRT_TRANSPORT_RDMA:
> -		if (mnt->mount_server.protocol == 0)
> -			mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
> -		if (mnt->timeo == 0)
> -			mnt->timeo = NFS_DEF_TCP_TIMEO;
> -		if (mnt->retrans == 0)
> -			mnt->retrans = NFS_DEF_TCP_RETRANS;
> 		break;
> 	default:
> 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> -		if (mnt->mount_server.protocol == 0)
> -			mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
> -		if (mnt->timeo == 0)
> -			mnt->timeo = NFS_DEF_TCP_TIMEO;
> -		if (mnt->retrans == 0)
> -			mnt->retrans = NFS_DEF_TCP_RETRANS;
> +	}
> +}
> +
> +/*
> + * For text based NFSv2/v3 mounts, the mount protocol transport  
> default
> + * settings should depend upon the specified NFS transport.
> + */
> +static void nfs_set_mount_transport_protocol(struct  
> nfs_parsed_mount_data *mnt)
> +{
> +	nfs_validate_transport_protocol(mnt);
> +
> +	if (mnt->mount_server.protocol == XPRT_TRANSPORT_UDP ||
> +	    mnt->mount_server.protocol == XPRT_TRANSPORT_TCP)
> +			return;
>
> +	switch (mnt->nfs_server.protocol) {
> +	case XPRT_TRANSPORT_UDP:
> +		mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
> 		break;
> +	case XPRT_TRANSPORT_TCP:
> +	case XPRT_TRANSPORT_RDMA:
> +		mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;

Nit: No "break;" here is asking for trouble down the road when we add  
more cases to this switch statement.

>
> 	}
> }
>
> @@ -1521,6 +1520,7 @@ static int nfs_validate_mount_data(void  
> *options,
> 	args->acdirmax		= NFS_DEF_ACDIRMAX;
> 	args->mount_server.port	= 0;	/* autobind unless user sets port */
> 	args->nfs_server.port	= 0;	/* autobind unless user sets port */
> +	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> 	args->auth_flavors[0]	= RPC_AUTH_UNIX;
>
> 	switch (data->version) {
> @@ -1625,7 +1625,7 @@ static int nfs_validate_mount_data(void  
> *options,
> 		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
> 				args->nfs_server.port);
>
> -		nfs_set_transport_defaults(args);
> +		nfs_set_mount_transport_protocol(args);
>
> 		status = nfs_parse_devname(dev_name,
> 					   &args->nfs_server.hostname,
> @@ -2235,6 +2235,7 @@ static int nfs4_validate_mount_data(void  
> *options,
> 		args->acdirmin	= data->acdirmin;
> 		args->acdirmax	= data->acdirmax;
> 		args->nfs_server.protocol = data->proto;
> +		nfs_validate_transport_protocol(args);
>
> 		break;
> 	default: {
> @@ -2250,7 +2251,7 @@ static int nfs4_validate_mount_data(void  
> *options,
> 		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
> 				args->nfs_server.port);
>
> -		nfs_set_transport_defaults(args);
> +		nfs_validate_transport_protocol(args);
>
> 		if (args->auth_flavor_len > 1)
> 			goto out_inval_auth;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 3c4078e..29d2619 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -12,8 +12,8 @@
> #include <linux/magic.h>
>
> /* Default timeout values */
> -#define NFS_DEF_UDP_TIMEO	(7)
> -#define NFS_DEF_UDP_RETRANS	(5)
> +#define NFS_DEF_UDP_TIMEO	(11)
> +#define NFS_DEF_UDP_RETRANS	(3)
> #define NFS_DEF_TCP_TIMEO	(600)
> #define NFS_DEF_TCP_RETRANS	(2)


As an aside, these macro values were copied from the default settings  
in the kernel's NFS mount option parser; so the values were always  
incorrect for text-based mounts even before 8b59ea3c.

Before I rewrote the nfs(5) man page recently, incidentally, it did  
claim that the retransmit timeout for UDP was 7 tenths of a second,  
and that the default retrans setting was 5.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
