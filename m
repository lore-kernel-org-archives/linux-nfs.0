Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480Ab3JYOIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 10:08:48 -0400
Date: Fri, 25 Oct 2013 10:08:46 -0400
To: Christoph Anton Mitterer <calestyo@scientia.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: XATTRs in NFS?
Message-ID: <20131025140846.GB20497@fieldses.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382635350.6907.83.camel@heisenberg.scientia.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 24, 2013 at 07:22:30PM +0200, Christoph Anton Mitterer wrote:
> On Thu, 2013-10-24 at 16:30 +0000, Myklebust, Trond wrote:
> > Those programs need to recompute the checksum data anyway in order to
> > verify and/or update it. Checksums that are computed by some third
> > party application have exactly zero value for integrity checking.
> No that's exactly the point,... the applications should _NOT_ set those
> checksums, especially not automagically (since then you'd never notice
> when just some application is buggy or writes/modifies when you don't
> expect it to do so).
> The idea is that there is on application (in my case it's just a
> script), which sets the integrity data and verifies it.
> 
> This works very well for e.g. large data archives, where you most of the
> time (but not always) only read files, write new files or move around
> existing ones - but only rarely modify existing file's contents.
> 
> 
> I do this already like that on local filesystems, which works very
> nicely with XATTRs... but now I want to move this on a central data
> cluster (where clients connect to via NFS)... and here the problems
> start... when I add new data to the archive (from the clients) I cannot
> have XATTRs attached, nor can I verify them form the clients.

Can you give any more details about your use case?  (E.g. is there an
article describing this system somewhere?)

Just curious.--b.
