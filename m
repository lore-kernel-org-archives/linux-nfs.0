Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbaCUUUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Mar 2014 16:20:44 -0400
Date: Fri, 21 Mar 2014 16:20:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: race-free exportfs and unmount?
Message-ID: <20140321202040.GC26831@fieldses.org>
References: <532C9E49.2030007@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <532C9E49.2030007@windriver.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 21, 2014 at 02:17:13PM -0600, Chris Friesen wrote:
> 
> Hi,
> 
> There was a linux-nfs thread in July 2012 with the subject "Linux
> NFS and cached properties".  It discussed the fact that you can't
> reliably do
> 
> exportfs -u 192.168.1.11:/mnt
> umount /mnt
> 
> since there could be rpc users still running when exportfs returns,
> so the umount fails thinking the filesystem is busy.

There could also be clients holding opens, locks, or delegations on the
export.

> I'm running into this on a production system.
> 
> Was anything ever done to resolve this issue?
> If not are there any workarounds?

You can shut down the server completely, unmount, and restart.

What is it you need to do exactly?

--b.
