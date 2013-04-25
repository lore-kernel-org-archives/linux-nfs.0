Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48289 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929Ab3DYNbB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 09:31:01 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: David Wysochanski <dwysocha@redhat.com>,
        Dave Chiluk <chiluk@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
Date: Thu, 25 Apr 2013 13:30:58 +0000
Message-ID: <1366896654.4719.18.camel@leira.trondhjem.org>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
	 <1366838926.22397.25.camel@leira.trondhjem.org>
	 <5178549A.7010402@canonical.com>
	 <1366842905.22397.49.camel@leira.trondhjem.org>
	 <1366892374.26249.294.camel@localhost.localdomain>
	 <20130425132907.GB31851@fieldses.org>
In-Reply-To: <20130425132907.GB31851@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-25 at 09:29 -0400, bfields@fieldses.org wrote:

> My position is that we simply have no idea what order of magnitude even
> delay should be.  And that in such a situation exponential backoff such
> as implemented in the synchronous case seems the reasonable default as
> it guarantees at worst doubling the delay while still bounding the
> long-term average frequency of retries.

So we start with a 15 second delay, and then go to 60 seconds?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
