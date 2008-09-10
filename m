From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Wed, 10 Sep 2008 11:12:04 -0400
Message-ID: <76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	 <m18wu1nyon.fsf@frodo.ebiederm.org>
	 <20080909152952.GA21207@us.ibm.com>
	 <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	 <m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Linux Containers" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "Cedric Le Goater" <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:59712 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbYIJPMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2008 11:12:07 -0400
Received: by gxk9 with SMTP id 9so13869764gxk.13
        for <linux-nfs@vger.kernel.org>; Wed, 10 Sep 2008 08:12:05 -0700 (PDT)
In-Reply-To: <48C791F9.8090606-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2008 at 5:23 AM, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> Eric W. Biederman wrote:
>> Chuck Lever <chuck.lever@oracle.com> writes:
>>
>>> If the upper layers are responsible for providing the utsname, you will need to
>>> fix up lockd and the NFS server's callback client too, at  least.
>>
>> Actually looking at the code.  It looks like a proper fix may be  even simpler.
>> Why do we have both clnt->cl_server and clnt->cl_nodename?    Or is cl_server
>> the other side of the connection?
>>
>>>>> What are we trying to achieve by reading utsname?
>>>> It looks like it gets copied into the sunrpc messages so I assume it is
>>>> a part of the sunrpc spec?
>>> It appears to be used only for RPC's AUTH_SYS credentials.  The nodename is used
>>> to identify the caller's host.  See RFC 1831,  Appendix A:
>>>
>>>   http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp
>>
>> Thanks that helps a lot.
>>
>>> I'm not terribly familiar with uts namespaces, though.  Can someone explain why
>>> we need to distinguish between these for AUTH_SYS if the  caller is on a remote
>>> system?
>>
>> Semantically processes in different uts namespaces are on different machines.
>>
>>> I don't like the idea of an oops in here.  Instead, (for now) it should warn and
>>> fail to create the client, IMO.
>>
>> Which is interesting when the problem happens during NFS unmount.  Although
>> frankly it could fail anyway.
>>
>> It seems strange that we are creating a client during unmount anyway.
>
> the task exiting brings down the lockd thread and unregisters the lockd service
> with the portmapper. This is done with a rpc call which creates a client and a
> request.

That makes sense.

This is likely coming from lockd_down(), and is almost certainly not
coming from the same uts namespace as the lockd_up() that did the
pmap_set, which was done by the first NFS mount done in the first uts
namespace on the system.  It's just something that the kernel has to
do for maintenance.

There is only one lockd() instance that is shared among all the uts
namespaces, right?  In this case, what is the correct utsname to use?

-- 
Chuck Lever
