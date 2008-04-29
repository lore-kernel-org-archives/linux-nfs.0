From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lock reclaims outside grace period
Date: Tue, 29 Apr 2008 15:18:51 -0700
Message-ID: <1209507531.8321.11.camel@heimdal.trondhjem.org>
References: <20080429215707.GF26468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:40912 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214AbYD2WSy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 18:18:54 -0400
In-Reply-To: <20080429215707.GF26468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-29 at 17:57 -0400, J. Bruce Fields wrote:
> Current lockd code appears to reject regular locks done during the grace
> period, but not reclaims that come outside of the grace period.
> 
> (That's based on inspecting the code--I haven't run tests.)
> 
> That seems like an obvious bug.  (We're not giving the client any way to
> determine whether conflicting locks might have been granted.)
> 
> Can we fix it, or is there a chance that people have been depending on
> this behavior?  (Maybe for failing over to an already-active server??)

Sorry, but I really don't care if anyone has been relying on it: that is
a _major_ bug and needs to be fixed ASAP.

  Trond

