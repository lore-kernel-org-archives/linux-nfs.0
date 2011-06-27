Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44472 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034Ab1F0WDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 18:03:17 -0400
Date: Mon, 27 Jun 2011 18:03:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v2] NFSD: Added basic fault injection
Message-ID: <20110627220316.GA11688@fieldses.org>
References: <4DD6AF42.5050502@netapp.com>
 <20110623195526.GA12357@fieldses.org>
 <4E087ABE.5090108@netapp.com>
 <4E08E1A0.9020101@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E08E1A0.9020101@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 27, 2011 at 04:01:36PM -0400, Bryan Schumaker wrote:
> On 06/27/2011 08:42 AM, Bryan Schumaker wrote:
> > On 06/23/2011 03:55 PM, J. Bruce Fields wrote:
> >> On Fri, May 20, 2011 at 02:13:22PM -0400, Bryan Schumaker wrote:
> >>> I have been looking at adding fault injection to the NFS server in order
> >>> to test the client's state manager and recovery threads.  Simulating
> >>> errors on the server seems like the easiest way to guarentee that
> >>> specific errors happen, and happen when we tell them to.
> >>>
> >>> This patch uses debugfs to add a simple framework for fault injection to
> >>> the server.  This framework is a config option, and can be enabled
> >>> through CONFIG_NFSD_FAULT_INJECTION.  Assuming you have debugfs mounted
> >>> to /sys/debug, a set of files will be created in /sys/debug/nfsd/.
> >>> Writing to any of these files will cause the corresponding action and
> >>> write a log entry to dmesg.
> >>>
> >>> Changes in v2:
> >>> - Replaced "forget all state owners" with "forget all open owners"
> >>> - Include fs/nfsd/fault_inject.c in the patch
> >>>
> >>> Suggestions?  Comments?
> >>
> >> If this is still the most recent version of the patch, and if you can
> >> confirm that this has been tried and found useful for testing the
> >> client, then I'll go ahead and apply for 3.1.
> > 
> > Yes, this is the most recent version of the patch.  It is part of my Jenkins setup, but I haven't been running it on a regular basis recently.
> 
> Trond and I just talked about more things to add in for fault injection, so I'll hopefully have a new version sometime in the near future.

OK, I'll hold off applying this for now.

--b.
