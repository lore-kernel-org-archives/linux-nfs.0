Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0196.hostedemail.com ([216.40.44.196]:55012 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752507AbdLDJsu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 04:48:50 -0500
Date: Mon, 4 Dec 2017 04:48:42 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: kernel-janitors@vger.kernel.org, linux-kselftest@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Trond Myklebust <trondmy@primarydata.com>
Subject: Re: Difficulties for compilation without extra optimisation
Message-ID: <20171204044842.0edbc51b@vmware.local.home>
In-Reply-To: <c834d3ed-3da3-e2b5-7f4b-9e36bfcb388b@users.sourceforge.net>
References: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
        <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
        <1512314250.3673.6.camel@primarydata.com>
        <20171203162256.4ea0750d@vmware.local.home>
        <c834d3ed-3da3-e2b5-7f4b-9e36bfcb388b@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 Dec 2017 10:00:54 +0100
SF Markus Elfring <elfring@users.sourceforge.net> wrote:

> > Why would you compile the kernel without optimization?  
> 
> Can another reason be occasionally still relevant?

No.

> 
> Will the compilation be a bit quicker when extra data processing
> could be omitted?

Why would you care more about the time it takes to compile the kernel,
than the time it takes for executing it? Benchmarks are all about
performance of a running kernel, nobody compares benchmarks of the time
it takes to compile it. Sure, we like to make the compile times quicker
(heck, I wrote "make localmodconfig" for just that purpose), but we
never favor compiler time over execution time. In fact, if we can
improve the execution performance by sacrificing compile time, we are
happy to do that.

> 
> 
> > There's many places in the kernel that WILL NOT BUILD without optimization.  
> 
> Would you like to keep the software situation in this way?

Yes.

> 
> 
> > In fact, we do a lot of tricks to make sure that things work the way
> > we expect it to, because we add broken code that only gets compiled out
> > when gcc optimizes the code the way we expect it to be,
> > and the kernel build will break otherwise.  
> 
> * Can this goal be also achieved without the addition of “broken code”?

No.

> 
> * How do you think about to improve the error handling there?

It works just fine as is. Errors that can be detected at build time are
100 times better than detecting them at execution time.

-- Steve
