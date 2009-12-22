From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS workloads
Date: Tue, 22 Dec 2009 05:01:46 -0800 (PST)
Message-ID: <787373.9318.qm@web113309.mail.gq1.yahoo.com>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>
To: Wu Fengguang <fengguang.wu@intel.com>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web113309.mail.gq1.yahoo.com ([98.136.167.9]:48061 "HELO
	web113309.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751153AbZLVNI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Dec 2009 08:08:28 -0500
In-Reply-To: <20091222015907.GA6223@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Wu Fengguang <fengguang.wu@intel.com>
> To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
> Cc: Peter Zijlstra <peterz@infradead.org>; "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>; "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>; jens.axboe <jens.axboe@oracle.com>
> Sent: Tue, December 22, 2009 2:59:07 AM
> Subject: Re: [PATCH] improve the performance of large sequential write NFS workloads
> 

[big snip]

> 
> In general it's reasonable to keep NFS per-file nr_dirty low, however
> questionable to do per-file nr_writeback throttling. This does not
> work well with the global limits - eg. when there are many dirty
> files, the summed-up nr_writeback will still grow out of control.
> And it's more likely to impact user visible responsiveness than
> a global limit. But my opinion can be biased -- me have a patch to
> do global NFS nr_writeback limit ;)
> 


 is that  "NFS: introduce writeback wait queue", which you sent me a while ago and I did not test until now :-( ?

Cheers
Martin
