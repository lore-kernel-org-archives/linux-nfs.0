From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Tue, 09 Sep 2008 13:08:29 -0700
Message-ID: <m17i9lm69u.fsf@frodo.ebiederm.org>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	<m1fxo9mba5.fsf@frodo.ebiederm.org>
	<869FF00C-4DAF-4D19-80AF-9230617A9223@oracle.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:42918 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbYIIUPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 16:15:03 -0400
In-Reply-To: <869FF00C-4DAF-4D19-80AF-9230617A9223@oracle.com> (Chuck Lever's
	message of "Tue, 9 Sep 2008 15:00:55 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Sep 9, 2008, at Sep 9, 2008, 2:20 PM, ebiederm@xmission.com wrote:
>> Chuck Lever <chuck.lever@oracle.com> writes:
>>
>>> If the upper layers are responsible for providing the utsname, you will need
>>> to
>>> fix up lockd and the NFS server's callback client too, at  least.
>>
>> Actually looking at the code.  It looks like a proper fix may be even simpler.
>> Why do we have both clnt->cl_server and clnt->cl_nodename?    Or is cl_server
>> the other side of the connection?
>
> cl_server is the server-side.  cl_nodename is the "machine name" of the client.

Thanks, Darn.  Looks like we need to capture both names at the same or a
similar point.

I'm wondering if we need to capture a network namespace as well.

>>> I don't like the idea of an oops in here.  Instead, (for now) it should warn
>>> and
>>> fail to create the client, IMO.
>>
>> Which is interesting when the problem happens during NFS unmount.  Although
>> frankly it could fail anyway.
>>
>> It seems strange that we are creating a client during unmount anyway.
>
> It's worth investigating.  Just enable RPC tracing (/usr/sbin/rpcdebug -m rpc -s
> all) before shutting down the client.
>
> NFS unmounting is historically difficult because during a system shutdown,
> unmounting is the last thing to occur, and usually happens  after most system
> services (such as the portmapper service) have become unavailable.  That's fine
> for local file systems, but it makes  for a rather dodgy situation for NFS.

Interesting.

Eric

