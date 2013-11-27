Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44731 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3K0Pri (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 10:47:38 -0500
Date: Wed, 27 Nov 2013 07:47:30 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] proc: change permission of /proc/self/mountstats to 0644
Message-ID: <20131127154730.GA26985@infradead.org>
References: <1385553135-23131-1-git-send-email-tigran.mkrtchyan@desy.de>
 <5069B68E-67AA-46C9-99C4-EE4839F71DFA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5069B68E-67AA-46C9-99C4-EE4839F71DFA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 27, 2013 at 10:21:29AM -0500, Chuck Lever wrote:
> That is true only if there is a single mount namespace on your system.  The content of mountstats depends on each process's mount namespace.
> 
> However, I see that mounts and mountinfo, which also depend on a process's mount namespace, are all S_IRUGO.  I don't see a good reason mountstats should be different.

Could any of the counters be used as a covert channel?  Any leakage of
information related to RPCSEC_GSS that could helper attackers?

