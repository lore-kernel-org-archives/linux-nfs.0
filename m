From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Tue, 09 Sep 2008 11:20:18 -0700
Message-ID: <m1fxo9mba5.fsf@frodo.ebiederm.org>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44571 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYIISZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 14:25:01 -0400
In-Reply-To: <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com> (Chuck Lever's
	message of "Tue, 9 Sep 2008 13:07:40 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> If the upper layers are responsible for providing the utsname, you will need to
> fix up lockd and the NFS server's callback client too, at  least.

Actually looking at the code.  It looks like a proper fix may be  even simpler.
Why do we have both clnt->cl_server and clnt->cl_nodename?    Or is cl_server
the other side of the connection?

>>> What are we trying to achieve by reading utsname?
>>
>> It looks like it gets copied into the sunrpc messages so I assume it is
>> a part of the sunrpc spec?
>
> It appears to be used only for RPC's AUTH_SYS credentials.  The nodename is used
> to identify the caller's host.  See RFC 1831,  Appendix A:
>
>   http://rfclibrary.hosting.com/rfc/rfc1831/rfc1831-16.asp

Thanks that helps a lot.

> I'm not terribly familiar with uts namespaces, though.  Can someone explain why
> we need to distinguish between these for AUTH_SYS if the  caller is on a remote
> system?

Semantically processes in different uts namespaces are on different machines.

> I don't like the idea of an oops in here.  Instead, (for now) it should warn and
> fail to create the client, IMO.

Which is interesting when the problem happens during NFS unmount.  Although
frankly it could fail anyway.

It seems strange that we are creating a client during unmount anyway.

Eric
