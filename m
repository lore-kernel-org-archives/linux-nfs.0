From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
 namespace is unshared
Date: Tue, 09 Sep 2008 13:54:39 +0200
Message-ID: <48C663FF.8020308@fr.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <m163p6pqkv.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:52201 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbYIILzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 07:55:03 -0400
In-Reply-To: <m163p6pqkv.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric W. Biederman wrote:
> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> 
>> On a system with nfs mounts, if a task unshares its mount namespace,
>> a oops can occur when the system is rebooted if the task is the last
>> to unreference the nfs mount. It will try to create a rpc request
>> using utsname() which has been invalidated by free_nsproxy().
>>
>> The patch fixes the issue by using the global init_utsname() but at
>> the same time, it breaks the capability of identifying rpc clients
>> per uts namespace.
>>
>> Any better suggestions ?
> 
> Can we push utsname into rpc_create_args and push the access
> of utsname up the food chain?

struct rpc_create_args seems to be used only as a stack argument 
for rpc_create() it's not kept in any nfs or sunrpc objects.
 
> My gut feeling says we should capture the utsname or the
> uts_ns when we mount the nfs filesystem so we stay in sync
> for the life of the mount.

I see. It make sense but, looking at the code, the nfs and sunrpc 
will need some heavy changes ...

Thanks,

C.
