From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 18:57:11 +1000
Message-ID: <48D217E7.80702@melbourne.sgi.com>
References: <124712.40022.qm@web32602.mail.mud.yahoo.com> <20080918014733.3c9c362e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Martin Knoblauch <knobi@knobisoft.de>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754755AbYIRI67@vger.kernel.org>
In-Reply-To: <20080918014733.3c9c362e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Morton wrote:
> On Thu, 18 Sep 2008 01:38:57 -0700 (PDT) Martin Knoblauch <knobi@knobisoft.de> wrote:
>
>   
>>> No.  mount(8) will pass unrecognised options straight down into the
>>> filesystem driver.
>>>
>>>       
>>  Has that always been the case, or is it a recent change? I have to support RHEL4 userland, which is not really new.
>>     
>
> It's been that way for ever and ever.  It's how all these guys:
>
> y:/usr/src/25> grep Opt_ fs/*/super.c|wc
>     781    2626   33703
>
> get handled.
>   
NFS was...special...for a long time.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
Be like the squirrel.
I don't speak for SGI.
