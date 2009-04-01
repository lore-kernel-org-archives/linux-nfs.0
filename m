From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in create_auth_rpc_client
	unless we need port
Date: Wed, 1 Apr 2009 14:01:30 -0400
Message-ID: <32D01620-325D-4D82-81EF-8584134BC7DC@oracle.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-4-git-send-email-jlayton@redhat.com>
	<F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
	<20090401134739.01b72029@barsoom.rdu.redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090401134739.01b72029@barsoom.rdu.redhat.com>
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

On Apr 1, 2009, at 1:47 PM, Jeff Layton wrote:
> On Wed, 1 Apr 2009 13:11:04 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> On Apr 1, 2009, at 10:24 AM, Jeff Layton wrote:
>>> We already have the server's address from the upcall, so we don't
>>> really
>>> need to look it up again. Move the getaddrinfo call in
>>> create_auth_rpc_client to a new function. Skip it if we already have
>>> the
>>> port in the sockaddr that we saved from the info in the upcall. If
>>> we need to get the port, don't bother looking up the hostname,  
>>> just do
>>> the getaddrinfo with AI_NUMERICHOST set.
>>>
>>> This should reduce the amount of lookups that are needed.
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> utils/gssd/gssd_proc.c |  134 ++++++++++++++++++++++++++++
>>> +-------------------
>>> 1 files changed, 81 insertions(+), 53 deletions(-)
>>>
>>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>>> index f5f3a0f..4d54c40 100644
>>> --- a/utils/gssd/gssd_proc.c
>>> +++ b/utils/gssd/gssd_proc.c
>>> @@ -538,6 +538,76 @@ out_err:
>>> }
>>>
>>> /*
>>> + * Determine the port from the servicename and set the right field
>>> in the
>>> + * sockaddr. This is mostly a no-op with newer kernels that send
>>> the port
>>> + * in the upcall. Returns true on success and false on failure.
>>> + */
>>> +static int
>>> +populate_port(struct sockaddr *sa, char *servicename, int socktype,
>>> +	      int protocol)
>>
>> I think you can guess the socktype from the protocol setting, so  
>> maybe
>> you don't need @socktype.  Actually, for AI_NUMERICHOST I don't think
>> protocol and socktype are even relevant.
>>
>
> It seems to me that getaddrinfo() needs to have some way to know
> whether you want the tcp or udp port for the service. I'm not sure
> whether it uses the ai_socktype or ai_protocol to determine this
> (probably the protocol), but I figure it doesn't hurt to set both.

As far as I understand it, the ai_socktype and ai_protocol fields are  
used to return the values needed for subsequent socket(2)/bind(2)  
system calls.  In this case you are not using these fields from the  
results...

If ai_protocol is zero, then getaddrinfo(3) assumes you want one copy  
of the address for each supported protocol type, so it returns three  
structures (one for IPPROTO_UDP, one for IPPROTO_TCP, and one with a  
zero protocol number).  The contents, except for the socktype and  
protocol fields, are the same for each.

You're using only the port number in the socket address, and ignoring  
the other contents.  So, yes, it works the same anyway, but it's  
confusing to read all the extra logic in populate_port().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
