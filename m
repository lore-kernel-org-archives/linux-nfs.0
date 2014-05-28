Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769AbaE1OCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 10:02:16 -0400
Date: Wed, 28 May 2014 10:01:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Message-ID: <20140528140151.GB13012@pad.redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-42-git-send-email-bfields@redhat.com>
 <20140528080945.GA6797@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140528080945.GA6797@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 01:09:45AM -0700, Christoph Hellwig wrote:
> On Thu, May 22, 2014 at 03:32:16PM -0400, J. Bruce Fields wrote:
> > Later patches handle those "exotic compounds", this one just makes sure
> > zero-copy is turned off in those cases.
> 
> How did you test these exotic compounds?

I have is a pynfs test that sends a compound with multiple reads in it.

I don't think that's pushed out to my regular pynfs tree, I'll try to do
that today.

I could really use more of those.  Maybe I'm wrong, but I'm worried less
about this case than the more finicky out-of-reply-space cases, where I
do have patches puporting to fix problems that I haven't really
verified.

--b.
