From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: referrals
Date: Thu, 08 May 2008 22:10:39 -0700
Message-ID: <1210309839.8657.0.camel@localhost>
References: <20080509011918.GK12690@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:50859 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbYEIFKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2008 01:10:47 -0400
In-Reply-To: <20080509011918.GK12690@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-05-08 at 21:19 -0400, J. Bruce Fields wrote:
> An attempt to follow an nfsv4 referral is leading to a hang.  I'm doing
> an "ls" on the absent directory.  A network trace shows the server
> returning with a sane-looking response to the getattr of fs_locations.
> I've appended the part of the sysrq-t trace for "ls".  Any ideas?
> 
> --b.

What kernel?

Trond

