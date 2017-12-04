Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:61556 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753092AbdLDJCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Dec 2017 04:02:22 -0500
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
Message-ID: <c834d3ed-3da3-e2b5-7f4b-9e36bfcb388b@users.sourceforge.net>
Date: Mon, 4 Dec 2017 10:00:54 +0100
MIME-Version: 1.0
In-Reply-To: <20171203162256.4ea0750d@vmware.local.home>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Why would you compile the kernel without optimization?

Can another reason be occasionally still relevant?

Will the compilation be a bit quicker when extra data processing
could be omitted?


> There's many places in the kernel that WILL NOT BUILD without optimization.

Would you like to keep the software situation in this way?


> In fact, we do a lot of tricks to make sure that things work the way
> we expect it to, because we add broken code that only gets compiled out
> when gcc optimizes the code the way we expect it to be,
> and the kernel build will break otherwise.

* Can this goal be also achieved without the addition of “broken code”?

* How do you think about to improve the error handling there?

Regards,
Markus
