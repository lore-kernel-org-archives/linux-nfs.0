Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53056 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753352Ab1DTJ2J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 05:28:09 -0400
Message-ID: <4DAEA782.2090108@cn.fujitsu.com>
Date: Wed, 20 Apr 2011 17:29:38 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svc: make sure mountd can get ports from /etc/services
References: <4DAD48C7.9090808@cn.fujitsu.com> <94B98C85-8FAE-4B72-A782-F0B0DFD83674@oracle.com>
In-Reply-To: <94B98C85-8FAE-4B72-A782-F0B0DFD83674@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Chuck Lever:
> Hi MJ-
> 
> On Apr 19, 2011, at 4:33 AM, Mi Jinlong wrote:
> 
>> At RHEL, if user set port for mountd at /etc/services as 
>> "mount   12345/tcp", mountd should be bind to 12345, but the 
>> latest nfs-utils, mountd get a rand port, not 12345.
>>
>> This patch make sure mountd be bind to the port which was set
>> at /etc/service.
> 
> I don't think this is documented anywhere.  Is there a reason it should work this way?
> 
> The typical way to set mountd's port is to use a command line option.  That's the way it works for all the other RPC daemons.  By default the ports are set up at random and registered with rpcbind.  That's why clients use rpcbind, and not /etc/services, to find these services.

  I don't have a depth research, agree with you.
  But I got different result when I set port for mountd at /etc/services
  between nfs-utils-1.2.3 and nfs-utils-1.2.2.

  I just think we should get the same result at new nfs-utils as older.

-- 
----
thanks
Mi Jinlong

> 
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>> support/include/rpcmisc.h |    1 +
>> support/nfs/svc_create.c  |    9 ++++-
>> support/nfs/svc_socket.c  |   83 +++++++++++++++++++++-----------------------
>> 3 files changed, 48 insertions(+), 45 deletions(-)
>>
>> diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
>> index 0b06457..b806227 100644
>> --- a/support/include/rpcmisc.h
>> +++ b/support/include/rpcmisc.h
>> @@ -53,6 +53,7 @@ void		rpc_init(char *name, int prog, int vers,
>> void		rpc_dispatch(struct svc_req *rq, SVCXPRT *xprt,
>> 				struct rpc_dtable *dtable, int nvers,
>> 				void *argp, void *resp);
>> +int		getservport(u_long number, const char *proto);
>>
>> extern int	_rpcpmstart;
>> extern int	_rpcfdtype;
>> diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
>> index b3f75ed..fd09902 100644
>> --- a/support/nfs/svc_create.c
>> +++ b/support/nfs/svc_create.c
>> @@ -393,7 +393,7 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
>> 	const struct sigaction create_sigaction = {
>> 		.sa_handler	= SIG_IGN,
>> 	};
>> -	unsigned int visible, up;
>> +	unsigned int visible, up, servport;
>> 	struct netconfig *nconf;
>> 	void *handlep;
>>
>> @@ -417,8 +417,13 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
>> 		if (!(nconf->nc_flag & NC_VISIBLE))
>> 			continue;
>> 		visible++;
>> +		if (port == 0)
>> +			servport = getservport(program, nconf->nc_proto);
>> +		else
>> +			servport = port;
>> +		
>> 		up += svc_create_nconf(name, program, version, dispatch,
>> -						port, nconf);
>> +						servport, nconf);
>> 	}
>>
>> 	if (visible == 0)
>> diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
>> index 03a5325..ec406a9 100644
>> --- a/support/nfs/svc_socket.c
>> +++ b/support/nfs/svc_socket.c
>> @@ -35,14 +35,46 @@
>> # define __close(f)		close ((f))
>> #endif
>>
>> +int getservport(u_long number, const char *proto)
>> +{
>> +	char rpcdata [1024], servdata [1024];
>> +	struct rpcent rpcbuf, *rpcp;
>> +	struct servent servbuf, *servp = NULL;
>> +	int ret;
>> +
>> +	ret = getrpcbynumber_r (number, &rpcbuf, rpcdata, sizeof rpcdata,
>> +				&rpcp);
>> +	if (ret == 0 && rpcp != NULL)
>> +	{
>> +		/* First try name.  */
>> +		ret = getservbyname_r (rpcp->r_name, proto, &servbuf, servdata,
>> +					sizeof servdata, &servp);
>> +		if ((ret != 0 || servp == NULL) && rpcp->r_aliases)
>> +		{
>> +			const char **a;
>> +
>> +			/* Then we try aliases.  */
>> +			for (a = (const char **) rpcp->r_aliases; *a != NULL; a++) 
>> +			{
>> +				ret = getservbyname_r (*a, proto, &servbuf, servdata,
>> +							sizeof servdata, &servp);
>> +				if (ret == 0 && servp != NULL)
>> +					break;
>> +			}
>> +		}
>> +	}
>> +
>> +	if (ret == 0 && servp != NULL)
>> +		return  ntohs(servp->s_port);
>> +
>> +	return 0;
>> +}
>> +
>> static int
>> svc_socket (u_long number, int type, int protocol, int reuse)
>> {
>>   struct sockaddr_in addr;
>>   socklen_t len = sizeof (struct sockaddr_in);
>> -  char rpcdata [1024], servdata [1024];
>> -  struct rpcent rpcbuf, *rpcp;
>> -  struct servent servbuf, *servp = NULL;
>>   int sock, ret;
>>   const char *proto = protocol == IPPROTO_TCP ? "tcp" : "udp";
>>
>> @@ -66,48 +98,13 @@ svc_socket (u_long number, int type, int protocol, int reuse)
>>
>>   memset (&addr, 0, sizeof (addr));
>>   addr.sin_family = AF_INET;
>> +  addr.sin_port = htons(getservport(number, proto));
>>
>> -  ret = getrpcbynumber_r (number, &rpcbuf, rpcdata, sizeof rpcdata,
>> -			  &rpcp);
>> -  if (ret == 0 && rpcp != NULL)
>> +  if (bind (sock, (struct sockaddr *) &addr, len) < 0)
>>     {
>> -      /* First try name.  */
>> -      ret = getservbyname_r (rpcp->r_name, proto, &servbuf, servdata,
>> -			     sizeof servdata, &servp);
>> -      if ((ret != 0 || servp == NULL) && rpcp->r_aliases)
>> -	{
>> -	  const char **a;
>> -
>> -	  /* Then we try aliases.  */
>> -	  for (a = (const char **) rpcp->r_aliases; *a != NULL; a++) 
>> -	    {
>> -	      ret = getservbyname_r (*a, proto, &servbuf, servdata,
>> -				     sizeof servdata, &servp);
>> -	      if (ret == 0 && servp != NULL)
>> -		break;
>> -	    }
>> -	}
>> -    }
>> -
>> -  if (ret == 0 && servp != NULL)
>> -    {
>> -      addr.sin_port = servp->s_port;
>> -      if (bind (sock, (struct sockaddr *) &addr, len) < 0)
>> -	{
>> -	  perror (_("svc_socket: bind problem"));
>> -	  (void) __close (sock);
>> -	  sock = -1;
>> -	}
>> -    }
>> -  else
>> -    {
>> -	  addr.sin_port = 0;
>> -	  if (bind (sock, (struct sockaddr *) &addr, len) < 0)
>> -	    {
>> -	      perror (_("svc_socket: bind problem"));
>> -	      (void) __close (sock);
>> -	      sock = -1;
>> -	    }
>> +      perror (_("svc_socket: bind problem"));
>> +      (void) __close (sock);
>> +      sock = -1;
>>     }
>>
>>   if (sock >= 0)
>> -- 
>> 1.7.4.1
>>
>>
>>
> 

