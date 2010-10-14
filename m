Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43219 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754744Ab0JNOLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:11:43 -0400
Date: Thu, 14 Oct 2010 10:11:42 -0400
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Effect of NFS4ERR_DELAY on the client
Message-ID: <20101014141142.GD24146@fieldses.org>
References: <4CB6EE0D.5060303@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB6EE0D.5060303@cea.fr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 14, 2010 at 01:48:29PM +0200, DENIEL Philippe wrote:
> Hi,
> 
> I have a question about NFS4ERR_DELAY. What is the behavior of the
> client when such an error is returned. Does it retry ? If yes, how
> many times and with what kind of interval between each retry ?
> Is the behavior similar to what the NFSv3 client when receiving
> NFS3ERR_JUKEBOX ?
> My purpose is to run NFSv4.x on top of a namespace whose entries can
> be migrated : opening a file may require staging it (in this case
> NFS4ERR_DELAY and NFS3ERR_JUKEBOX will be returned)

For the linux client, see fs/nfs/nfs4proc.c:nfs4_delay() and
nfs4_handle_exception():  looks like it starts with NFS4_POLL_RETRY_MIN
== .1 second, and doubles it each time up to NFS4_POLL_RETRY_MAX == 15
seconds.

--b.
