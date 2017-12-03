Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:57676 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751781AbdLCV5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Dec 2017 16:57:32 -0500
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
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <bd57d7d5-c8f5-0bc9-c96f-37550557dca3@users.sourceforge.net>
Date: Sun, 3 Dec 2017 22:56:51 +0100
MIME-Version: 1.0
In-Reply-To: <20171203162256.4ea0750d@vmware.local.home>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Why would you compile the kernel without optimization?

I would like to see how big an effect finally is in such a build configuration
after specific source code adjustments.


> There's many places in the kernel that WILL NOT BUILD without optimization.

I did not really know this detail so far.

I noticed that the optimised build variants worked during my test comparisons.


> In fact, we do a lot of tricks to make sure that things work the way
> we expect it to, because we add broken code that only gets compiled out
> when gcc optimizes the code the way we expect it to be,
> and the kernel build will break otherwise.

Thanks for your information.

Can the software areas distinguished where such special handling matters?

Regards,
Markus
