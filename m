Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35973 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752920Ab1H0AqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 20:46:21 -0400
Date: Fri, 26 Aug 2011 20:46:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] nfsd4: This is: "fix failure to end nfsd4 grace period"
 ++
Message-ID: <20110827004618.GG18699@fieldses.org>
References: <4E45C594.1030609@panasas.com>
 <20110826201910.GB17196@fieldses.org>
 <4E5838E0.4090703@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E5838E0.4090703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 26, 2011 at 05:22:56PM -0700, Boaz Harrosh wrote:
> Which of the variables has the directory path?
> Would we like to add that information in the print. From my experience
> alot of times those type of problems is the mis-communication of
> the path names, and it helps to see what name was actually attempted.

Yeah, I wanted to then realized I'd have to muck about with some other
stuff to get access to the directory name.

Curse these patch reviewers, catching me being lazy.

--b.
