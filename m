Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487Ab1LASJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 13:09:51 -0500
Date: Thu, 1 Dec 2011 13:09:50 -0500
To: Upendra Moturi <upendra.m@hexagrid.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: need help for locking with nfs4
Message-ID: <20111201180950.GA6845@fieldses.org>
References: <CAHbZLqTLHo7FYKmLUbi5OP4=8_O+obOvtFR=6+Dfs+tozJiwKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHbZLqTLHo7FYKmLUbi5OP4=8_O+obOvtFR=6+Dfs+tozJiwKA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 03:43:03PM +0530, Upendra Moturi wrote:
> Hi
> 
> I need some example to configure nfs4 mandatory locking.
> I have setup nfs4 server and client.
> I want to enable mandatory locking so that no two clients can access
> file at same time.

What exactly do you mean by "mandatory locking", and why isn't advisory
fcntl-based locking sufficient?

--b.
