Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:62561 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752874AbdLDKTl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Dec 2017 05:19:41 -0500
Subject: Re: Difficulties for compilation without extra optimisation
To: Steven Rostedt <rostedt@goodmis.org>,
        kernel-janitors@vger.kernel.org
Cc: linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Trond Myklebust <trondmy@primarydata.com>
References: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
 <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
 <1512314250.3673.6.camel@primarydata.com>
 <20171203162256.4ea0750d@vmware.local.home>
 <c834d3ed-3da3-e2b5-7f4b-9e36bfcb388b@users.sourceforge.net>
 <20171204044842.0edbc51b@vmware.local.home>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <1b850dea-fdea-cc93-65fb-ba5e2082bcb9@users.sourceforge.net>
Date: Mon, 4 Dec 2017 11:18:26 +0100
MIME-Version: 1.0
In-Reply-To: <20171204044842.0edbc51b@vmware.local.home>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Will the compilation be a bit quicker when extra data processing
>> could be omitted?
> 
> Why would you care more about the time it takes to compile the kernel,
> than the time it takes for executing it?

I am also interested in the evolution of compilation time frames.


> Benchmarks are all about performance of a running kernel,

This is generally reasonable.


> nobody compares benchmarks of the time it takes to compile it.

I guess that the situation can be occasionally different there.


> Sure, we like to make the compile times quicker

Good to know …


> (heck, I wrote "make localmodconfig" for just that purpose),

Thanks.


> but we never favor compiler time over execution time.

I imagine that the speed expectations could be adjusted during software development,
couldn't they?


> In fact, if we can improve the execution performance by sacrificing compile time,
> we are happy to do that.

I guess that you would like to consider some constraints there.


>>> In fact, we do a lot of tricks to make sure that things work the way
>>> we expect it to, because we add broken code that only gets compiled out
>>> when gcc optimizes the code the way we expect it to be,
>>> and the kernel build will break otherwise.  
>>
>> * Can this goal be also achieved without the addition of “broken code”?
> 
> No.

Will any other contributors take another look?


>> * How do you think about to improve the error handling there?
> 
> It works just fine as is.

I hope that further software improvements can be achieved also for this use case.


> Errors that can be detected at build time are 100 times better
> than detecting them at execution time.

I agree to such a general view.

Will an other (or no) error message be more appropriate?

Regards,
Markus
