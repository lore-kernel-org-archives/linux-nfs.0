From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/22] SUNRPC: pass buffer size to svc_addsock() and
	svc_sock_names()
Date: Mon, 15 Dec 2008 16:17:18 -0500
Message-ID: <20081215211718.GH26769@fieldses.org>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215804.24332.24605.stgit@ingres.1015granger.net> <4945437E.3090305@opengridcomputing.com> <7998F1F2-05DD-44AB-B023-80C49DABAD9B@oracle.com> <4946C6A6.4050602@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, aime.le-rouzic@bull.net,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53192 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661AbYLOVRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 16:17:24 -0500
In-Reply-To: <4946C6A6.4050602@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 15, 2008 at 03:05:42PM -0600, Tom Tucker wrote:
> Chuck Lever wrote:
>> On Dec 14, 2008, at 12:33 PM, Tom Tucker wrote:
>>> Hi Chuck:
>>>
>>> This whole svc_addsock business is an artifact of rpc.xxx creating a  
>>> socket in user mode and then passing the fd down to the kernel via a  
>>> write to the portlist file. Would it be easier, cleaner, etc... to  
>>> normalize this whole business to use strings exclusively to create  
>>> these sockets?
>>>
>>> E.g. echo "tcp6 2049" > /proc/fs/nfsd/portlist
>>>
>>> You could quite simply extend the syntax as well to support listening 
>>> on specific interfaces.
>>
>> That would be Bruce's decision.  It doesn't seem like a bad idea.
>>
>> Some folks question the idea of using netids like "tcp6" for kernel  
>> interfaces.  I'm on the fence.  RDMA doesn't have an official netid 
>> yet, for example.
>
> Ok clearly there are (at least) two issues. One is mechanical; how do we  
> get the NFS server side transport instantiated. The second is: what do  
> the "identifiers" represent?
>
> I'm advocating that the mechanism be normalized so that we can get rid  
> of code that duplicates functionality.

We shouldn't remove interfaces.

(There may be exceptions: for example, if nfs-utils has never used this
fd-passing feature and google doesn't turn up evidence that anyone else
has either.  Or if it's really totally broken and impossible to support.
Even then we would probably phase it out somehow, e.g. by adding a
warning first.)

--b.

>
> Perhaps this is naive, but could we simply call it an "NFS Transport  
> Identifier" such that the only thing it "means" is the election of the  
> transport provider invoked to instantiate the service?
>
>>
>>> Tom
>>>
>>> Chuck Lever wrote:
>>>> Pass the size of the output buffer to the RPC functions that construct
>>>> the list of socket names in that buffer.  Add documenting comments to
>>>> these functions.
>>>>
>>>> This is a cosmetic change for now.  A subsequent patch will make sure
>>>> the buffer length is passed to one_sock_name(), where the length will
>>>> actually be useful.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> fs/nfsd/nfsctl.c               |   12 ++++++++----
>>>> include/linux/sunrpc/svcsock.h |    6 ++++--
>>>> net/sunrpc/svcsock.c           |   34 +++++++++++++++++++++++++++++-----
>>>> 3 files changed, 41 insertions(+), 11 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>>> index 22fc8e5..19db9f4 100644
>>>> --- a/fs/nfsd/nfsctl.c
>>>> +++ b/fs/nfsd/nfsctl.c
>>>> @@ -898,7 +898,7 @@ static ssize_t __write_ports_names(char *buf,  
>>>> size_t size)
>>>> static ssize_t __write_ports_addfd(char *buf, size_t size)
>>>> {
>>>>     char *mesg = buf;
>>>> -    int fd, err;
>>>> +    int fd, err, len;
>>>>      err = get_int(&mesg, &fd);
>>>>     if (err || fd < 0)
>>>> @@ -908,13 +908,16 @@ static ssize_t __write_ports_addfd(char *buf, 
>>>> size_t size)
>>>>     if (err)
>>>>         return err;
>>>> -    err = svc_addsock(nfsd_serv, fd, buf);
>>>> +    len = SIMPLE_TRANSACTION_LIMIT;
>>>> +    err = svc_addsock(nfsd_serv, fd, buf, len);
>>>>     if (err < 0)
>>>>         return err;
>>>> +    len -= err;
>>>>      err = lockd_up();
>>>>     if (err < 0)
>>>> -        svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
>>>> +        svc_sock_names(nfsd_serv, buf + strlen(buf) + 1,
>>>> +                len - strlen(buf) - 1, buf);
>>>>      /* Decrease the count, but don't shut down the the service */
>>>>     nfsd_serv->sv_nrthreads--;
>>>> @@ -935,7 +938,8 @@ static ssize_t __write_ports_delfd(char *buf,  
>>>> size_t size)
>>>>         return -ENOMEM;
>>>>      if (nfsd_serv)
>>>> -        len = svc_sock_names(buf, nfsd_serv, toclose);
>>>> +        len = svc_sock_names(nfsd_serv, buf,
>>>> +                    SIMPLE_TRANSACTION_LIMIT, toclose);
>>>>     if (len >= 0)
>>>>         lockd_down();
>>>> diff --git a/include/linux/sunrpc/svcsock.h  
>>>> b/include/linux/sunrpc/svcsock.h
>>>> index 483e103..f57ce85 100644
>>>> --- a/include/linux/sunrpc/svcsock.h
>>>> +++ b/include/linux/sunrpc/svcsock.h
>>>> @@ -38,8 +38,10 @@ int        svc_recv(struct svc_rqst *, long);
>>>> int        svc_send(struct svc_rqst *);
>>>> void        svc_drop(struct svc_rqst *);
>>>> void        svc_sock_update_bufs(struct svc_serv *serv);
>>>> -int        svc_sock_names(char *buf, struct svc_serv *serv, char  
>>>> *toclose);
>>>> -int        svc_addsock(struct svc_serv *serv, int fd, char  
>>>> *name_return);
>>>> +int        svc_sock_names(struct svc_serv *serv, char *buf, size_t 
>>>> buflen,
>>>> +                    char *toclose);
>>>> +int        svc_addsock(struct svc_serv *serv, int fd, char  
>>>> *name_return,
>>>> +                    size_t len);
>>>> void        svc_init_xprt_sock(void);
>>>> void        svc_cleanup_xprt_sock(void);
>>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>> index a1951dc..39f5015 100644
>>>> --- a/net/sunrpc/svcsock.c
>>>> +++ b/net/sunrpc/svcsock.c
>>>> @@ -263,8 +263,23 @@ static int one_sock_name(char *buf, struct  
>>>> svc_sock *svsk)
>>>>     return len;
>>>> }
>>>> -int
>>>> -svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
>>>> +/**
>>>> + * svc_sock_names - construct a list of listener names in a string
>>>> + * @serv: pointer to RPC service
>>>> + * @buf: pointer to a buffer to fill in with socket names
>>>> + * @buflen: size of the buffer to be filled
>>>> + * @toclose: pointer to '\0'-terminated C string containing the name
>>>> + *        of a listener to be closed
>>>> + *
>>>> + * Fills in @buf with a '\n'-separated list of names of listener
>>>> + * sockets.  If @toclose is not NULL, the socket named by @toclose
>>>> + * is closed, and is not included in the output list.
>>>> + *
>>>> + * Returns positive length of the socket name string, or a negative
>>>> + * errno value on error.
>>>> + */
>>>> +int svc_sock_names(struct svc_serv *serv, char *buf, size_t buflen,
>>>> +           char *toclose)
>>>> {
>>>>     struct svc_sock *svsk, *closesk = NULL;
>>>>     int len = 0;
>>>> @@ -1165,9 +1180,18 @@ static struct svc_sock  
>>>> *svc_setup_socket(struct svc_serv *serv,
>>>>     return svsk;
>>>> }
>>>> -int svc_addsock(struct svc_serv *serv,
>>>> -        int fd,
>>>> -        char *name_return)
>>>> +/**
>>>> + * svc_addsock - add a listener socket to an RPC service
>>>> + * @serv: pointer to RPC service to which to add a new listener
>>>> + * @fd: file descriptor of the new listener
>>>> + * @name_return: pointer to buffer to pass back name of listener
>>>> + * @len: size of the buffer
>>>> + *
>>>> + * Fills in socket name and returns positive length of name if  
>>>> successful.
>>>> + * Name is terminated with '\n'.  On error, returns a negative errno
>>>> + * value.
>>>> + */
>>>> +int svc_addsock(struct svc_serv *serv, int fd, char *name_return,  
>>>> size_t len)
>>>> {
>>>>     int err = 0;
>>>>     struct socket *so = sockfd_lookup(fd, &err);
>>>>
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
