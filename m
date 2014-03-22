Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pfw.demon.co.uk ([62.49.22.168]:44736 "EHLO pfw.demon.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbaCVKSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 06:18:07 -0400
Date: Sat, 22 Mar 2014 10:11:04 +0000
From: Larry Keegan <lk@pfw.demon.co.uk>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <neilb@suse.de>,
        <linux-nfs@vger.kernel.org>
Subject: Re: race-free exportfs and unmount?
Message-ID: <20140322101104.56dd99a0@cs3.al.itld>
In-Reply-To: <532CA76B.8050300@windriver.com>
References: <532C9E49.2030007@windriver.com>
	<20140321202040.GC26831@fieldses.org>
	<532CA76B.8050300@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Mar 2014 14:56:11 -0600
Chris Friesen <chris.friesen@windriver.com> wrote:
> On 03/21/2014 02:20 PM, J. Bruce Fields wrote:
> > On Fri, Mar 21, 2014 at 02:17:13PM -0600, Chris Friesen wrote:
> >>
> >> Hi,
> >>
> >> There was a linux-nfs thread in July 2012 with the subject "Linux
> >> NFS and cached properties".  It discussed the fact that you can't
> >> reliably do
> >>
> >> exportfs -u 192.168.1.11:/mnt

You forgot echo /mnt > /proc/fs/nfsd/unlock_filesystem

> >> umount /mnt
> >>
> >> since there could be rpc users still running when exportfs returns,
> >> so the umount fails thinking the filesystem is busy.

This is almost always the case on an active NFS server. Stuff 'em! Just
unlock the filesystem and your drbd flip should work just fine. I've
been doing it for years.

BOFH.
