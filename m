From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with krb5 authentification, server under a NAT
Date: Tue, 22 Apr 2008 15:15:57 -0400
Message-ID: <20080422191557.GC21770@fieldses.org>
References: <20080422161908.GC11221@goelette.ens.fr>
	<20080422165620.GF16695@fieldses.org>
	<480E3730.7040305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, steved@redhat.com
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <480E3730.7040305@citi.umich.edu>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 22, 2008 at 03:06:24PM -0400, Olga Kornievskaia wrote:
>
>
> J. Bruce Fields wrote:
>> On Tue, Apr 22, 2008 at 06:19:09PM +0200, Quentin Godfroy wrote:
>>   
>>> Hi,
>>>
>>> I have a problem with krb5 authentification and nfsv4:
>>>
>>> basically the server is behind a NAT which over I do not have much control.
>>> To mount exported partitions I use socat on the NAT and redirect some TCP port
>>> (actually 2050 because 2049 is firewalled) to the port 2049 on the server. I
>>> can successfuly mount with auth=sys,port=2050, but I am unable to mount with
>>> kerberos authentification. The problem seems to lie within rpc.gssd which does
>>> not care for the port setting and tries to contact the server on port 2049.
>>>
>>> I suppose the same could happen with nfsv{2,3} (provided the mountd port is
>>> redirected as well)
>>>
>>> Is this a problem you were aware of?
>>>
>>> I suppose fixing it may require a change in the callback between the kernel
>>> and rpc.gssd?
>>>     
>>
>> What kernel are you on?  As of 2.6.24 (more specifically:
>>
>> 	bf19aacecbeebccb2c3d150a8bd9416b7dba81fe "nfs: add server port
>> 	to rpc_pipe info file"
>>
>> the kernel does give gssd the information it needs to figure out which
>> port the server is on.
>>
>> Looks to me like gssd doesn't yet use that yet, though.  Olga, did you
>> have a patch to make gssd read the "port:" line from the info file?
>>   
> We'll try to create a new nfs-utils-citi-all patch that includes this,  
> but for now try the attached file.

I think this is ready to go upstream, too.

--b.

>
> >From 3506247fd27131c0a2f9b8ef9ad2fe794d07beac Mon Sep 17 00:00:00 2001
> From: Olga Kornievskaia <aglo@citi.umich.edu>
> Date: Thu, 7 Feb 2008 11:43:40 -0500
> Subject: [PATCH] gssd_read_port
> 
> ---
>  utils/gssd/gssd.h      |    1 +
>  utils/gssd/gssd_proc.c |   14 ++++++++++++--
>  2 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 65182a5..5d88fd8 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -82,6 +82,7 @@ struct clnt_info {
>  	int			krb5_poll_index;
>  	int			spkm3_fd;
>  	int			spkm3_poll_index;
> +	int			port;
>  };
>  
>  void init_client_list(void);
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 40c0b9a..c832ac6 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -102,7 +102,7 @@ int pollsize;  /* the size of pollaray (in pollfd's) */
>  /* XXX buffer problems: */
>  static int
>  read_service_info(char *info_file_name, char **servicename, char **servername,
> -		  int *prog, int *vers, char **protocol) {
> +		  int *prog, int *vers, char **protocol, int *port) {
>  #define INFOBUFLEN 256
>  	char		buf[INFOBUFLEN];
>  	static char	dummy[128];
> @@ -112,6 +112,8 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  	char		program[16];
>  	char		version[16];
>  	char		protoname[16];
> +	char		cb_port[128];
> +	char		*p;
>  	in_addr_t	inaddr;
>  	int		fd = -1;
>  	struct hostent	*ent = NULL;
> @@ -143,6 +145,10 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  		goto fail;
>  	}
>  
> +	cb_port[0] = '\0';
> +	if ((p = strstr(buf, "port")) != NULL)
> +		sscanf(p, "port: %127s\n", cb_port);
> +
>  	/* check service, program, and version */
>  	if (memcmp(service, "nfs", 3))
>  		return -1;
> @@ -171,6 +177,8 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
>  		goto fail;
>  	memcpy(*servicename, buf, strlen(buf));
> +	if (cb_port[0] != '\0')
> +		*port = atoi(cb_port);
>  
>  	if (!(*protocol = strdup(protoname)))
>  		goto fail;
> @@ -246,7 +254,7 @@ process_clnt_dir_files(struct clnt_info * clp)
>  	if ((clp->servicename == NULL) &&
>  	     read_service_info(info_file_name, &clp->servicename,
>  				&clp->servername, &clp->prog, &clp->vers,
> -				&clp->protocol))
> +				&clp->protocol, &clp->port))
>  		return -1;
>  	return 0;
>  }
> @@ -628,6 +636,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
>  			 clp->servername, uid);
>  		goto out_fail;
>  	}
> +	if (clp->port)
> +		((struct sockaddr_in *)a->ai_addr)->sin_port = htons(clp->port);
>  	if (a->ai_protocol == IPPROTO_TCP) {
>  		if ((rpc_clnt = clnttcp_create(
>  					(struct sockaddr_in *) a->ai_addr,
> -- 
> 1.5.3.7
> 
