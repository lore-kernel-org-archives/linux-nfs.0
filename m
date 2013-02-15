Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36336 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756779Ab3BOSZc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 13:25:32 -0500
Date: Fri, 15 Feb 2013 13:25:31 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: V4 unmount causes a GETATTR
Message-ID: <20130215182531.GB19923@fieldses.org>
References: <511E5838.2020103@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511E5838.2020103@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 15, 2013 at 10:46:00AM -0500, Steve Dickson wrote:
> Hello,
> 
> I have not tracked down as to the exact reason, 
> but it appears umount of v4 file system cause the
> directory to be revalidating causing the  GETATTR. 
> 
> Is this revalidation really necessary on an unmount? 

I don't know, maybe not.  But even if it's not, there are other things
(like cleaning up state) that the client will likely try to do on
unmount.  In the presence of delegations it could have dirty data that
it's required to write back even if applications don't currently hold
any open files.

So I don't think we can promise umount will work without the network.

--b.
