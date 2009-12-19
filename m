From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Sat, 19 Dec 2009 09:08:24 +0100
Message-ID: <20091219090824.1bc4a1c8@infradead.org>
References: <1261015420.1947.54.camel@serenity>
	<1261037877.27920.36.camel@laptop>
	<1261164799.1947.123.camel@serenity>
	<20091218194129.GB6153@elte.hu>
	<1261171211.1947.135.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond.Myklebust@netapp.com, Wu Fengguang <fengguang.wu@intel.com>,
	"jens.axboe" <jens.axboe@oracle.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50578 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbZLSIGR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Dec 2009 03:06:17 -0500
In-Reply-To: <1261171211.1947.135.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Dec 2009 16:20:11 -0500
Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org> wrote:

> 
> I don't disagree, but "that's not what we do" hardly provides insight
> into making the judgment call.  In this case, the variety of
> combinations of NFS server speed, NFS client speed, transmission link
> speed, client memory size, and server memory size argues for a tunable
> parameter, because one value probably won't work well in all
> combinations.  Making it change dynamically based on these parameters
> is more complicated than these circumstances call for, IMHO.


if you as the expert do not know how to tune this... how is a sysadmin
supposed to know better?


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
