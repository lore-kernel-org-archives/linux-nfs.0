From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/6] SUNRPC: Display some debugging information as text rather than numbers
Date: Wed, 21 May 2008 16:57:46 -0400
Message-ID: <19E2AC1E-94E9-4E66-A645-F61CE7C1F451@oracle.com>
References: <20080521180231.3295.84997.stgit@ellison> <20080521181620.3295.2298.stgit@ellison> <20080521195041.GC6712@fieldses.org> <0276F8AD-8401-4991-803F-581E37223397@oracle.com> <20080521204216.GE8375@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29636 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbYEUU6P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 16:58:15 -0400
In-Reply-To: <20080521204216.GE8375@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 21, 2008, at 4:42 PM, J. Bruce Fields wrote:
> On Wed, May 21, 2008 at 04:37:23PM -0400, Chuck Lever wrote:
>>
>> On May 21, 2008, at 3:50 PM, J. Bruce Fields wrote:
>>
>>> On Wed, May 21, 2008 at 02:16:20PM -0400, Chuck Lever wrote:
> ...
>>>> +	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:=
=20
>>>> %s
>>>> \n",
>>>> +		task->tk_pid, task->tk_flags, task->tk_status,
>>>> +		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
>>>> +		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
>>>> +		action, queue);
>>>
>>> "net/sunrpc/clnt.c: In function =91rpc_show_task=92:
>>> net/sunrpc/clnt.c:1555: error: =91queue=92 undeclared (first use in=
 this
>>> function)
>>> net/sunrpc/clnt.c:1555: error: (Each undeclared identifier is =20
>>> reported
>>> only once
>>> net/sunrpc/clnt.c:1555: error: for each function it appears in.)"
>>>
>>> Is that last "queue" supposed to be "rpc_waitq"???
>>
>> Yes... I fixed that already... was that in the version I sent out =20
>> this
>> afternoon?
>
> Yup.  See the attribution above, or the "In-Reply-To" header, or
> http://marc.info/?l=3Dlinux-nfs&m=3D121139389532042&w=3D2.

That's exceedingly odd.  I mailed these out *after* I had build-tested =
=20
and run against ying2 this afternoon.

I will send another set.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com