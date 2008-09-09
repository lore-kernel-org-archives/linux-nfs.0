From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Tue, 9 Sep 2008 13:07:40 -0400
Message-ID: <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42179 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbYIIRJ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 13:09:59 -0400
In-Reply-To: <20080909152952.GA21207@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 9, 2008, at Sep 9, 2008, 11:29 AM, Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> "Serge E. Hallyn" <serue@us.ibm.com> writes:
>>
>>> Thanks, Cedric.  Eric is probably right about the long-term fix, but
>>> yeah it might take a while to properly wade through the sunrpc and  
>>> nfs
>>> layers to store the nodename at nfs mount time, and in the  
>>> meantime this
>>> fixes a real oops.
>>
>> A very esoteric oops that hasn't shown up for two years.
>
> But an easily reproducible one.
>
> It's not as though we'll stop looking for the right fix just bc we  
> have
> this "bad" fix in for a short while.
>
>> Please let's look at this and see what it would take to fix this
>> properly.
>
> Of course.  Cedric is looking at the best way to fix it...

If the upper layers are responsible for providing the utsname, you  
will need to fix up lockd and the NFS server's callback client too, at  
least.

>> What are we trying to achieve by reading utsname?
>
> It looks like it gets copied into the sunrpc messages so I assume it  
> is
> a part of the sunrpc spec?

It appears to be used only for RPC's AUTH_SYS credentials.  The  
nodename is used to identify the caller's host.  See RFC 1831,  
Appendix A:

   http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp

I'm not terribly familiar with uts namespaces, though.  Can someone  
explain why we need to distinguish between these for AUTH_SYS if the  
caller is on a remote system?

> I don't want to do this, but we *could* put a conditional in utsname()
> to have it return init_utsname if current->nsproxy is null...

I don't like the idea of an oops in here.  Instead, (for now) it  
should warn and fail to create the client, IMO.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
