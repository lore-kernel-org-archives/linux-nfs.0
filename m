Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51140 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbeBYXyw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 25 Feb 2018 18:54:52 -0500
Date: Sun, 25 Feb 2018 18:54:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: xfstests EBUSY on generic/32, generic/247
Message-ID: <20180225235451.GA12646@fieldses.org>
References: <20180223160350.GF15876@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180223160350.GF15876@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 23, 2018 at 11:03:50AM -0500, bfields wrote:
> Starting somewhere between v4.15-rc1 and v4.16-rc1, I'm getting sporadic
> failures: either on generic/32, with "pread64: Device or resource busy",
> or generic/247, on "mmap: Device or resource busy".  Anyone else aware
> of this?
> 
> Annoyingly, I haven't been able to reproduce yet by running just those
> tests, I only reproduce reliably with a 1-2 hour test run.  I'll see if
> I can narrow it down any more....

And now I can't reproduce it at all.  Maybe there was some problem with
the exported xfs filesystem?  I guess I'm giving up for now.

--b.
