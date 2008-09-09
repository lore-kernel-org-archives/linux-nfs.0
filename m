From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
	namespace is unshared
Date: Tue, 9 Sep 2008 15:00:55 -0400
Message-ID: <869FF00C-4DAF-4D19-80AF-9230617A9223@oracle.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	<m1fxo9mba5.fsf@frodo.ebiederm.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: ebiederm@xmission.com
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <m1fxo9mba5.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 9, 2008, at Sep 9, 2008, 2:20 PM, ebiederm@xmission.com wrote:
> Chuck Lever <chuck.lever@oracle.com> writes:
>
>> If the upper layers are responsible for providing the utsname, you  
>> will need to
>> fix up lockd and the NFS server's callback client too, at  least.
>
> Actually looking at the code.  It looks like a proper fix may be   
> even simpler.
> Why do we have both clnt->cl_server and clnt->cl_nodename?    Or is  
> cl_server
> the other side of the connection?

cl_server is the server-side.  cl_nodename is the "machine name" of  
the client.

>>>> What are we trying to achieve by reading utsname?
>>>
>>> It looks like it gets copied into the sunrpc messages so I assume  
>>> it is
>>> a part of the sunrpc spec?
>>
>> It appears to be used only for RPC's AUTH_SYS credentials.  The  
>> nodename is used
>> to identify the caller's host.  See RFC 1831,  Appendix A:
>>
>>  http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp
>
> Thanks that helps a lot.
>
>> I'm not terribly familiar with uts namespaces, though.  Can someone  
>> explain why
>> we need to distinguish between these for AUTH_SYS if the  caller is  
>> on a remote
>> system?
>
> Semantically processes in different uts namespaces are on different  
> machines.

OK.

>> I don't like the idea of an oops in here.  Instead, (for now) it  
>> should warn and
>> fail to create the client, IMO.
>
> Which is interesting when the problem happens during NFS unmount.   
> Although
> frankly it could fail anyway.
>
> It seems strange that we are creating a client during unmount anyway.

It's worth investigating.  Just enable RPC tracing (/usr/sbin/rpcdebug  
-m rpc -s all) before shutting down the client.

NFS unmounting is historically difficult because during a system  
shutdown, unmounting is the last thing to occur, and usually happens  
after most system services (such as the portmapper service) have  
become unavailable.  That's fine for local file systems, but it makes  
for a rather dodgy situation for NFS.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
