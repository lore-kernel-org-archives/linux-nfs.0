Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46319 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab0ITPEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 11:04:40 -0400
Date: Mon, 20 Sep 2010 11:03:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: iisaman@umich.edu
Cc: linux-nfs@vger.kernel.org
Subject: Re: hang on server boot
Message-ID: <20100920150317.GE4580@fieldses.org>
References: <20100920033621.GB18325@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100920033621.GB18325@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Sep 19, 2010 at 11:36:21PM -0400, bfields wrote:
> Trying to do some reboot testing, I hit this bug.  I'm planning to queue
> up this fix for 2.6.37 absent any objections.
> 
> (Arguably it could go to 2.6.36, but we're getting closer to the next
> release, the consequences of this bug aren't too horrible, and it's not
> a new regression.)

With that kernel fix and the following two pynfs fixes, I pass the
reboot tests except for REBT4, 5, 6, 7, and 11 (which I haven't tried to
triage yet).

--b.
