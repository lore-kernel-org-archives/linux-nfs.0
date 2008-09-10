From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Wed, 10 Sep 2008 16:54:15 -0400
Message-ID: <C67C0244-EBA8-4E8C-94D8-E815DC1F979D@oracle.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com> <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com> <m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com> <76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com> <m1ej3rixbx.fsf@frodo.ebiederm.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: chucklever@gmail.com, "Cedric Le Goater" <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Linux Containers" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:10536 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYIJU5S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2008 16:57:18 -0400
In-Reply-To: <m1ej3rixbx.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 10, 2008, at Sep 10, 2008, 4:02 PM, ebiederm@xmission.com wrote:
> "Chuck Lever" <chuck.lever@oracle.com> writes:
>> That makes sense.
>>
>> This is likely coming from lockd_down(), and is almost certainly not
>> coming from the same uts namespace as the lockd_up() that did the
>> pmap_set, which was done by the first NFS mount done in the first uts
>> namespace on the system.  It's just something that the kernel has to
>> do for maintenance.
>>
>> There is only one lockd() instance that is shared among all the uts
>> namespaces, right?  In this case, what is the correct utsname to use?
>
> Interesting.
>
> As a general rule I would say we should capture the uts instance
> in locked_up().  And use the same instance in locked_down().
>
> I'm not at all familiar with how locked interacts with nfs mounts
> in a practical sense.  Is there one locked instance (or at least  
> context)
> per nfs mount?
>
> The way I would expect things to work is that when we mount an nfs  
> filesystem
> from an nfs server.  We would create a locked context for that  
> server, that
> additional nfs mounts to the same nfs server could share.

There is one lockd, one statd, and one rpcbind per client.  These are  
shared between all the NFS mounts on the client.  Likewise, there is  
one of each of these per server, and they are shared among all exports.

lockd_up() and lockd_down() maintain a count of mounts and exports,  
and lockd_down() shuts down lockd when the count goes to zero.

statd provides the ability to signal a server when a client reboots  
(and vice versa). This gives the server an indication of when to free  
locks for any applications on a rebooting client, and gives the client  
an indication of when it needs to reclaim locks on a rebooting server.

statd (user space) and lockd (kernel) have to share a cookie  
(mon_name) which is used to identify the client to servers, and the  
server to clients, so reboots can be detected.  That cookie would  
probably need to be the initial utsname.

> The way I would expect nfs to interact with the namespaces is for  
> the nfs
> mount to capture the uts and network namespaces, and use them for all
> transactions relating to the mount.

That works for the main NFS protocol, perhaps, but the auxiliary  
protocols are another matter.  They operate on behalf of a whole  
client or server, not on behalf of an individual mount or export.

>  In particular when creating
> or a locked context the nfs mount would use the uts namespace and the
> network namespace as discriminators to see if an existing locked  
> context
> is the same.

Possible, but I would expect this to be a lot of work for not much  
gain.  The right answer is likely that you need a lockd and statd  
instance (virtual or real) for each namespace.  The mounts and exports  
in each namespace would have their own lockd and statd.

> I don't think nfs has a 1-1 thread to context model which is where  
> things
> get really hazy for me.

Users are assigned credentials.  The credentials are passed from  
client to server, and the server does work on behalf of that  
credential (user).  lockd uses a credential and a process identifier  
to find locks on files.

AUTH_SYS credentials (the lowest common denominator) are constructed  
from the user's UID and GID and the client's utsname.

The kernel, then, will have to construct unique credentials for users  
in each uts namespace.  This is likely not an NFS mount-time issue,  
but is instead part of the mechanism of mapping requests from  
processes to RPC credentials.

> The conservative play is to always force use of the initial namespace
> and to deny creation of mounts that would use different namespaces.   
> In part
> because the initial version of the namespace always exists.  Which  
> means
> as relates to Cedrics initial patch we would still need to know which
> mounts should cause us to use a different uts namespace so we can deny
> them.

OK.  I think what you are saying is that NFS won't work outside of the  
initial uts namespace, for now?

Also, how would an automounter fit into this uts namespace scheme?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
