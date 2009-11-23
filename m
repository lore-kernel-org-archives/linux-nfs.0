From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.31 under "heavy" NFS load.
Date: Mon, 23 Nov 2009 16:27:26 -0500
Message-ID: <20091123212726.GC8534@fieldses.org>
References: <4AF86DE4.5010607@krogh.cc> <20091110184126.GD15000@fieldses.org> <4AF9B994.8040301@krogh.cc> <4B05A91D.1090305@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46697 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202AbZKWV0m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:26:42 -0500
In-Reply-To: <4B05A91D.1090305-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 19, 2009 at 09:22:53PM +0100, Jesper Krogh wrote:
> Ok, I still haven't had the "excact same" workload put on the host, but
> it has been running on the patched kernel for 8 days now and I havent
> seen load numbers over 32 while service 1100MB/s over NFS (dd'ing 512
> bytes blocks out of the server from the clients) while doing local disk
> IO for an iowait of ~25% (4 cores sucking what they can). This workload
> is "similar" to the one sending it to load numbers of over 100 earlier.
> 
> So I'm confident that the problem is solved by reverting the patch.

OK, I'm applying the revert for 2.6.33.

--b.
