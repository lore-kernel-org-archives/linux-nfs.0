From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/2] asynchronous unlock on exit
Date: Mon, 31 Mar 2008 14:24:35 -0400
Message-ID: <47F12C63.3030108@redhat.com>
References: <20080328201229.18158.52437.stgit@c-69-242-210-120.hsd1.mi.comcast.net>	 <47ED6534.9080604@redhat.com> <1206742095.15567.44.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787AbYCaSYz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2008 14:24:55 -0400
In-Reply-To: <1206742095.15567.44.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2008-03-28 at 17:37 -0400, Peter Staubach wrote:
>
>   
>> However, I think that nlmclnt_unlock() needs to wait until
>> the RPC is completed.
>>     
>
> It should do that now. See the call to rpc_wait_for_completion_task() in
> nlm_async_call()
>
>   

Ahh, yes, sorry, was misreading the patch.
>>   The original problem was test12() in
>> the Connectathon testsuite, which would occasionally fail.
>> It would fail because the parent would kill the child process
>> (actually the child of the child) and immediately attempt to
>> grab the lock.  This would fail because the child hadn't
>> completed releasing the lock yet.  There were some timing
>> dependencies in test12() itself, which I eliminated, but then
>> discovered that this wouldn't solve the entire problem.  (I
>> can send you the new version of test12(), if you wish.)
>>     
>
> So, at least in 2.6.25, the call to rpc_wait_for_completion_task() will
> exit only on a fatal signal. The problem in test12() is that there is a
> 'pre-existing condition', in that the parent signalled us with a SIGINT,
> and so the signal is set upon entry to the function.
>
> IOW: we might have to perform a similar trick to what do_coredump()
> does, and clear the TIF_SIGPENDING flag. I'm not sure if that is
> sufficient, but given that we're eliminating the calls to
> recalc_sigpending(), and that there should be no such calls left in the
> RPC code, I think we're OK.

I suspect that we are okay too, but I will try this and then allow
the RHTS folks to play with it as well.  They are the ones seeing
the failures, so hopefully this will make them happy.

    Thanx!

       ps
