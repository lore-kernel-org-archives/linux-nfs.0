Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750889Ab1HLUgP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2011 16:36:15 -0400
Date: Fri, 12 Aug 2011 16:36:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812203606.GL16960@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
 <4E447EEB.501@panasas.com>
 <4E4481F0.2050806@panasas.com>
 <20110812021556.GD9761@pad.fieldses.org>
 <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com>
 <20110812143228.GD16960@pad.fieldses.org>
 <4E456BBB.1030605@panasas.com>
 <20110812183945.GJ16960@pad.fieldses.org>
 <4E45785D.40103@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E45785D.40103@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 12:00:45PM -0700, Boaz Harrosh wrote:
> On 08/12/2011 11:39 AM, J. Bruce Fields wrote:
> > On Fri, Aug 12, 2011 at 11:06:51AM -0700, Boaz Harrosh wrote:
> >> I'm confused is this suppose to fix my problem? Because I do not believe
> >> it will. There should not be any error writing a recovery record.
> >>
> >> Please note that the case I have is that the client is a new client. That
> >> loaded after the server loaded and started it's grace. Does a client suppose
> >> to send RECLAIM_COMPLETE in that case too. .i.e send RECLAIM_COMPLETE as first
> >> message after mount?
> > 
> > It must send one before it sends any non-reclaim open, yes.
> > 
> 
> 1. So you are saying the Linux client is broken? How do you test?

Which linux client version, again?  See:

	"Whenever a client establishes a new client ID and before it does
	the first non-reclaim operation that obtains a lock, it MUST
	send a RECLAIM_COMPLETE with rca_one_fs set to FALSE, even if
	there are no locks to reclaim."

I thought it was only very early ("experimental") 4.1 clients that
omitted RECLAIM_COMPLETE?

Is this actually the deleg reclaim case that Trond mentioned?  Could I
see a trace?

--b.
