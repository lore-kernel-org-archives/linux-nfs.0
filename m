From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: high latency NFS
Date: Mon, 04 Aug 2008 19:25:54 +1000
Message-ID: <4896CB22.4000005@melbourne.sgi.com>
References: <200807241311.31457.shuey@purdue.edu> <20080804003206.GB6119@disturbed> <20080804011158.GA8066@fieldses.org> <200808041118.19743.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:36754 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750998AbYHDJdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 05:33:08 -0400
In-Reply-To: <200808041118.19743.bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bernd Schubert wrote:
> On Monday 04 August 2008 03:11:58 J. Bruce Fields wrote:
>   
>> OK, so to summarize: when the rate of incoming rpc's is very high (and,
>> I guess, when we're serving everything out of cache and don't have IO
>> wait), all the nfsd threads will stay runable all the time.  That keeps
>> userspace processes from running (possibly for "minutes").  And that's a
>> problem even on a server dedicated only to nfs, since it affects portmap
>> and rpc.mountd.
>>     
>
> Even worse, it affects user space HA software such as heartbeat and everyone 
> with reasonable timeouts will see spurious 'failures'. 
>   
We're seeing that problem right now, even with the patch.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

