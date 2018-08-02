Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36026 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732531AbeHBQGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 12:06:19 -0400
Date: Thu, 2 Aug 2018 10:14:55 -0400
To: Peter Scott <pjscott@jpl.nasa.gov>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 file lock reporting interface request
Message-ID: <20180802141455.GB31569@fieldses.org>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 09, 2018 at 07:28:53PM -0700, Peter Scott wrote:
> Hello.  I am with the institutional hosting service at NASA's Jet
> Propulsion Laboratory and we have been trying to find the answer to
> an apparently simple question.
> 
> We are running an NFSv4 server on Centos 7 and we need to get the
> server to tell us which files it thinks are locked by which
> clients.  This is because we have observed failure modes where
> something apparently has a lock (because attempting to lock the file
> again blocks) but we can't find a client that has the lock. Finding
> out what the server believes would be critical to troubleshooting
> this.
> 
> We tracked down Trond Myklebust and Neil Brown and conversation
> suggests that this is a function that is (a) not currently available
> and (b) reasonable to ask for.  So this is me suggesting that an
> interface be provided to have knfsd output its list of locked files
> and clients.

Yes, we really need to do that.  If anyone has the cycles to take it on
I'm happy to talk about it.  Otherwise, I'll get to it myself
eventually....

--b.
