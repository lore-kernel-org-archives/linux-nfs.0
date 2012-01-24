Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754588Ab2AXS3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 13:29:04 -0500
Date: Tue, 24 Jan 2012 13:29:03 -0500
To: Nick Bowler <nbowler@elliptictech.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: NFS auth_rpcgss client crash in 3.3-rc1+ (regression)
Message-ID: <20120124182903.GA10964@fieldses.org>
References: <20120124041251.GA16952@elliptictech.com>
 <20120124164144.GA19315@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120124164144.GA19315@elliptictech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2012 at 11:41:44AM -0500, Nick Bowler wrote:
> On 2012-01-23 23:12 -0500, Nick Bowler wrote:
> > I'm seeing crashes similar to the following with latest Linus' git on an
> > NFSv4 client machine.  User home directories are NFS mounted with
> > sec=krb5, and the crash often occurs immediately or shortly after the
> > first successful login.  However, it does not always crash: it happens
> > maybe 50% of the time.  Most of the time the box is dead as a result.
> > 
> > I see this in Linux 3.3-rc1 as well, but I've not had a chance to bisect
> > it yet (might be tricky since it's not 100% reliable).  The server is
> > running Linux 3.2.1.
> 
> I forgot to mention that this is a regression from 3.2 on the client.

Might be the same as this?:

	http://marc.info/?l=linux-nfs&m=132734162715894&w=2

--b.
