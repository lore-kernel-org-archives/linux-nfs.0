Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40948 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750932AbdFWPZc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 11:25:32 -0400
Date: Fri, 23 Jun 2017 11:25:32 -0400
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: linux-nfs@vger.kernel.org, it+linux-nfs@molgen.mpg.de
Subject: Re: Full volume causes some NFS clients to get client ID expired
 responses
Message-ID: <20170623152532.GB31966@fieldses.org>
References: <03f0da7e-99c1-a015-c701-b8c8f4a6ec85@molgen.mpg.de>
 <6c0fa7f4-a179-4b7e-9f52-abfa80df3bb4@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6c0fa7f4-a179-4b7e-9f52-abfa80df3bb4@molgen.mpg.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 21, 2017 at 01:48:05PM +0200, Paul Menzel wrote:
> We experience the following behavior with the Linux series 4.4 and 4.9.

So, your NFS server is a Linux server running kernel 4.4 or 4.9?  What
is the exported filesystem?

What are the clients?

> When the exported directory on the server gets full to 100 % some NFS
> clients are unable to access the server anymore, but others can.
> 
> The error is, that the server says the client ID has expired.

Where exactly are you seeing that error, in response to what operation?

Might be interesting to try a more recent kernel.

--b.
