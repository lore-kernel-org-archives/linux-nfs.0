From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/6] SUNRPC: Display some debugging information as text
	rather than numbers
Date: Wed, 21 May 2008 16:42:16 -0400
Message-ID: <20080521204216.GE8375@fieldses.org>
References: <20080521180231.3295.84997.stgit@ellison> <20080521181620.3295.2298.stgit@ellison> <20080521195041.GC6712@fieldses.org> <0276F8AD-8401-4991-803F-581E37223397@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935315AbYEUUmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 16:42:38 -0400
In-Reply-To: <0276F8AD-8401-4991-803F-581E37223397@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 21, 2008 at 04:37:23PM -0400, Chuck Lever wrote:
>
> On May 21, 2008, at 3:50 PM, J. Bruce Fields wrote:
>
>> On Wed, May 21, 2008 at 02:16:20PM -0400, Chuck Lever wrote:
=2E..
>>> +	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:%=
s=20
>>> \n",
>>> +		task->tk_pid, task->tk_flags, task->tk_status,
>>> +		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
>>> +		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
>>> +		action, queue);
>>
>> "net/sunrpc/clnt.c: In function =E2=80=98rpc_show_task=E2=80=99:
>> net/sunrpc/clnt.c:1555: error: =E2=80=98queue=E2=80=99 undeclared (f=
irst use in this =20
>> function)
>> net/sunrpc/clnt.c:1555: error: (Each undeclared identifier is report=
ed=20
>> only once
>> net/sunrpc/clnt.c:1555: error: for each function it appears in.)"
>>
>> Is that last "queue" supposed to be "rpc_waitq"???
>
> Yes... I fixed that already... was that in the version I sent out thi=
s =20
> afternoon?

Yup.  See the attribution above, or the "In-Reply-To" header, or
http://marc.info/?l=3Dlinux-nfs&m=3D121139389532042&w=3D2.

--b.
