From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/22] SUNRPC: pass buffer size to svc_addsock() and svc_sock_names()
Date: Mon, 29 Dec 2008 14:24:15 -0500
Message-ID: <926E9A27-74B3-438D-B314-96CBE67697D9@oracle.com>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215804.24332.24605.stgit@ingres.1015granger.net> <20081225044306.GC17998@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:43867 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbYL2TYd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Dec 2008 14:24:33 -0500
In-Reply-To: <20081225044306.GC17998@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 24, 2008, at Dec 24, 2008, 11:43 PM, J. Bruce Fields wrote:
> On Fri, Dec 12, 2008 at 04:58:05PM -0500, Chuck Lever wrote:
>> Pass the size of the output buffer to the RPC functions that  
>> construct
>> the list of socket names in that buffer.  Add documenting comments to
>> these functions.
>>
>> This is a cosmetic change for now.  A subsequent patch will make sure
>> the buffer length is passed to one_sock_name(), where the length will
>> actually be useful.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfsd/nfsctl.c               |   12 ++++++++----
>> include/linux/sunrpc/svcsock.h |    6 ++++--
>> net/sunrpc/svcsock.c           |   34 ++++++++++++++++++++++++++++ 
>> +-----
>> 3 files changed, 41 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 22fc8e5..19db9f4 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -898,7 +898,7 @@ static ssize_t __write_ports_names(char *buf,  
>> size_t size)
>> static ssize_t __write_ports_addfd(char *buf, size_t size)
>> {
>> 	char *mesg = buf;
>> -	int fd, err;
>> +	int fd, err, len;
>>
>> 	err = get_int(&mesg, &fd);
>> 	if (err || fd < 0)
>> @@ -908,13 +908,16 @@ static ssize_t __write_ports_addfd(char *buf,  
>> size_t size)
>> 	if (err)
>> 		return err;
>>
>> -	err = svc_addsock(nfsd_serv, fd, buf);
>> +	len = SIMPLE_TRANSACTION_LIMIT;
>> +	err = svc_addsock(nfsd_serv, fd, buf, len);
>> 	if (err < 0)
>> 		return err;
>> +	len -= err;
>>
>> 	err = lockd_up();
>> 	if (err < 0)
>> -		svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
>> +		svc_sock_names(nfsd_serv, buf + strlen(buf) + 1,
>> +				len - strlen(buf) - 1, buf);
>
> Since you already did len -= err above, aren't you effectly subtracing
> off strlen(buf) twice here?

Yeah, that's a bug, but relatively harmless.  I'll change that.

> (And should that "len -= err" actually have
> been a "len -= err + 1"?)

Looking at this again, I think the pre-existing "+ 1" is incorrect.

Say we have an 8 byte buffer, and svc_addsock() returns a 4-byte name,  
let's say "xyz\n".

It's my impression that we then want svc_sock_names() to start filling  
in at the 5th byte in the buffer, which is buf[4] (or buf + 4) because  
C arrays are indexed starting at zero.

There are four bytes remaining in the buffer, so 8 - 4 = 4 is still  
correct.

So we want something like this:

	len = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
	/* error checking snipped */
	svc_socknames(nfsd_serv, buf + len, SIMPLE_TRANSACTION_LIMIT - len,  
buf);

Do you agree?

It's hard to see how today's nfs-utils would even exercise this case.   
NFSD appears to open portlist for reading only to get the current set  
of listeners; and when adding a new listener, it only writes.  I was  
not able to find a case where it reads back what was written -- the  
portlist file is opened WR_ONLY.

Also, I'm not sure about the logic around the lockd_up() call and the  
thread count bumping.  There were some changes around this area in  
October of 2006 where the lockd_up() call was done before the  
svc_addsock() call, but at that time lockd_up() took a protocol  
number, so it had to be moved after svc_addsock().  It doesn't  
anymore, so we can probably go back to the original logic here which  
did a lockd_down() if an error occurred adding the new transport.   
Neil, what do you think?

The thread count manipulation is somewhat less obvious.  I'm not sure  
why we should decrement sv_nrthreads if the svc_addsock() call  
succeeded.

>> 	/* Decrease the count, but don't shut down the the service */
>> 	nfsd_serv->sv_nrthreads--;
>> @@ -935,7 +938,8 @@ static ssize_t __write_ports_delfd(char *buf,  
>> size_t size)
>> 		return -ENOMEM;
>>
>> 	if (nfsd_serv)
>> -		len = svc_sock_names(buf, nfsd_serv, toclose);
>> +		len = svc_sock_names(nfsd_serv, buf,
>> +					SIMPLE_TRANSACTION_LIMIT, toclose);
>> 	if (len >= 0)
>> 		lockd_down();
>>
>> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/ 
>> svcsock.h
>> index 483e103..f57ce85 100644
>> --- a/include/linux/sunrpc/svcsock.h
>> +++ b/include/linux/sunrpc/svcsock.h
>> @@ -38,8 +38,10 @@ int		svc_recv(struct svc_rqst *, long);
>> int		svc_send(struct svc_rqst *);
>> void		svc_drop(struct svc_rqst *);
>> void		svc_sock_update_bufs(struct svc_serv *serv);
>> -int		svc_sock_names(char *buf, struct svc_serv *serv, char  
>> *toclose);
>> -int		svc_addsock(struct svc_serv *serv, int fd, char *name_return);
>> +int		svc_sock_names(struct svc_serv *serv, char *buf, size_t buflen,
>> +					char *toclose);
>> +int		svc_addsock(struct svc_serv *serv, int fd, char *name_return,
>> +					size_t len);
>> void		svc_init_xprt_sock(void);
>> void		svc_cleanup_xprt_sock(void);
>>
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index a1951dc..39f5015 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -263,8 +263,23 @@ static int one_sock_name(char *buf, struct  
>> svc_sock *svsk)
>> 	return len;
>> }
>>
>> -int
>> -svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
>> +/**
>> + * svc_sock_names - construct a list of listener names in a string
>> + * @serv: pointer to RPC service
>> + * @buf: pointer to a buffer to fill in with socket names
>> + * @buflen: size of the buffer to be filled
>> + * @toclose: pointer to '\0'-terminated C string containing the name
>> + *		of a listener to be closed
>> + *
>> + * Fills in @buf with a '\n'-separated list of names of listener
>> + * sockets.  If @toclose is not NULL, the socket named by @toclose
>> + * is closed, and is not included in the output list.
>> + *
>> + * Returns positive length of the socket name string, or a negative
>> + * errno value on error.
>> + */
>> +int svc_sock_names(struct svc_serv *serv, char *buf, size_t buflen,
>> +		   char *toclose)
>> {
>> 	struct svc_sock *svsk, *closesk = NULL;
>> 	int len = 0;
>> @@ -1165,9 +1180,18 @@ static struct svc_sock  
>> *svc_setup_socket(struct svc_serv *serv,
>> 	return svsk;
>> }
>>
>> -int svc_addsock(struct svc_serv *serv,
>> -		int fd,
>> -		char *name_return)
>> +/**
>> + * svc_addsock - add a listener socket to an RPC service
>> + * @serv: pointer to RPC service to which to add a new listener
>> + * @fd: file descriptor of the new listener
>> + * @name_return: pointer to buffer to pass back name of listener
>> + * @len: size of the buffer
>> + *
>> + * Fills in socket name and returns positive length of name if  
>> successful.
>> + * Name is terminated with '\n'.  On error, returns a negative errno
>> + * value.
>> + */
>> +int svc_addsock(struct svc_serv *serv, int fd, char *name_return,  
>> size_t len)
>> {
>> 	int err = 0;
>> 	struct socket *so = sockfd_lookup(fd, &err);
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




