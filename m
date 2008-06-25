From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [PATCH] NFSD: fix use of setsockopt
Date: Wed, 25 Jun 2008 16:44:15 -0400
Message-ID: <4862AE1F.5050902@citi.umich.edu>
References: <485A6033.3090301@citi.umich.edu> <20080625193757.GF12629@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:36111 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285AbYFYUoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2008 16:44:19 -0400
In-Reply-To: <20080625193757.GF12629@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Thu, Jun 19, 2008 at 09:33:39AM -0400, Olga Kornievskaia wrote:
>   
>> The following patch fixes NFS server's use of setsockopt. For this  
>> function to take an effect it first needs be called after socket  
>> creation but before sock binding.
>>     
>
> The tcp(7) man page actually claims that it's listen() and connect()
> that matter (so the setsockopt is effective on (and only on) unconnected
> sockets), so probably this could go after the bind and before the
> listen?  Not that it matters.
>
>   
>> This patch also changes the size of the receive sock buffer to be same  
>> as the send sock buffer. Both buffers are now a multiple of maxpayload  
>> and number of nfsd threads.
>>     
>
> It would be nice if we could get some review from someone who remembers
> what the justification for the smaller receive buffer size was (Neil?).
>
>   
>> This patch fixes the problem that receive window never opens beyond the  
>> default TCP receive window size set by the 2nd parameter of the  
>> net.ipv4.tcp_rmem sysctl.
>>     
>
> Do you know what it does in the udp case?
>   
Looking at the kernel code, when setsockopt() is called on a UDP socket 
to set send/receive buffer for UPD the code will not do anything: 
udp_setsockopt() and udp_lib_setsockopt() will return -ENOPROTOOPT. 
However, we bypass the call to setsockopt() and instead set the buffer 
sizes directly. From what I understand sk_sndbuf/sk_rcvbuf are not used 
by the UDP code. We are setting the fields that are never used.

Then perhaps we can remove calls to svc_sock_setbufsize() from 
svc_udp_init() and svc_udp_recvfrom()?
> --b.
>
>   
>> Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
>>     
>
>   
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index c75bffe..178b397 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -1191,7 +1191,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
>>  		 */
>>  		svc_sock_setbufsize(svsk->sk_sock,
>>  				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
>> -				    3 * serv->sv_max_mesg);
>> +				    (serv->sv_nrthreads+3) * serv->sv_max_mesg);
>>  
>>  	clear_bit(SK_DATA, &svsk->sk_flags);
>>  
>> @@ -1372,11 +1372,6 @@ svc_tcp_init(struct svc_sock *svsk)
>>  		 * receive and respond to one request.
>>  		 * svc_tcp_recvfrom will re-adjust if necessary
>>  		 */
>> -		svc_sock_setbufsize(svsk->sk_sock,
>> -				    3 * svsk->sk_server->sv_max_mesg,
>> -				    3 * svsk->sk_server->sv_max_mesg);
>> -
>> -		set_bit(SK_CHNGBUF, &svsk->sk_flags);
>>  		set_bit(SK_DATA, &svsk->sk_flags);
>>  		if (sk->sk_state != TCP_ESTABLISHED)
>>  			set_bit(SK_CLOSE, &svsk->sk_flags);
>> @@ -1761,6 +1756,8 @@ static int svc_create_socket(struct svc_serv *serv, int protocol,
>>  
>>  	if (type == SOCK_STREAM)
>>  		sock->sk->sk_reuse = 1;		/* allow address reuse */
>> +	svc_sock_setbufsize(sock, (serv->sv_nrthreads+3) * serv->sv_max_mesg,
>> +				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
>>  	error = kernel_bind(sock, sin, len);
>>  	if (error < 0)
>>  		goto bummer;
>>     
>
>
>   
