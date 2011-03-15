Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56612 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756204Ab1COVa4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2011 17:30:56 -0400
Date: Tue, 15 Mar 2011 17:30:44 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Dax Kelson <dkelson@gurulabs.com>, linux-nfs@vger.kernel.org
Subject: Re: When did NFSv4 behavior change occur?
Message-ID: <20110315213044.GA2292@fieldses.org>
References: <1300120256.3600.19.camel@mentorng>
 <4D7E4EFF.9060302@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D7E4EFF.9060302@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 14, 2011 at 01:23:11PM -0400, Steve Dickson wrote:
> 
> 
> On 03/14/2011 12:30 PM, Dax Kelson wrote:
> > In a quest to update our documentation, could someone please answer this
> > question?
> > 
> > What kernel version did the change occur where all the entries
> > in /etc/exports are shared as v4 (in addition to v2 and v3) as well as
> > the automatic psuedo-root creation if fsid=0 not exist?
> kernel-2.6.32.

Looks like 2.6.33 was actually the first released kernel.

(Found just by 'git log fs/nfsd', grepping for 'V4ROOT', then doing 'git
describe --contains <commit I found>'.)

--b.

> > Or maybe it was a combo of kernel version and nfs-utils version??
> nfs-utils-1.2.2
> 
> steved.
> 
> > 
> > Dax Kelson
> > Guru Labs
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
