Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678Ab1HLSjx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2011 14:39:53 -0400
Date: Fri, 12 Aug 2011 14:39:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812183945.GJ16960@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
 <4E447EEB.501@panasas.com>
 <4E4481F0.2050806@panasas.com>
 <20110812021556.GD9761@pad.fieldses.org>
 <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com>
 <20110812143228.GD16960@pad.fieldses.org>
 <4E456BBB.1030605@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E456BBB.1030605@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 11:06:51AM -0700, Boaz Harrosh wrote:
> I'm confused is this suppose to fix my problem? Because I do not believe
> it will. There should not be any error writing a recovery record.
> 
> Please note that the case I have is that the client is a new client. That
> loaded after the server loaded and started it's grace. Does a client suppose
> to send RECLAIM_COMPLETE in that case too. .i.e send RECLAIM_COMPLETE as first
> message after mount?

It must send one before it sends any non-reclaim open, yes.

--b.
