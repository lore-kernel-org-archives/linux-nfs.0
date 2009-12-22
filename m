From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Tue, 22 Dec 2009 13:38:35 +0100
Message-ID: <1261485515.4937.28.camel@laptop>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity>
	 <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Wu Fengguang <fengguang.wu@intel.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33595 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbZLVMjZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Dec 2009 07:39:25 -0500
In-Reply-To: <20091222122557.GA604-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-12-22 at 13:25 +0100, Jan Kara wrote:
>   I believe that if we had per-bdi dirty_background_ratio and set it low
> for NFS's bdi, 

There's two things there I think:
 1) bdi_background
 2) different background ratios per bdi

1) could be 'trivially' done much like we do bdi_dirty in
get_dirty_limits().

2) I'm not at all convinced we want to go there.

