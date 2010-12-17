Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out.good-with-numbers.com ([64.142.29.24]:2018 "EHLO
	out.good-with-numbers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab0LQDSz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 22:18:55 -0500
Date: Thu, 16 Dec 2010 19:18:54 -0800
From: Mike <debian@good-with-numbers.com>
To: linux-nfs@vger.kernel.org
Subject: Re: nfs-common needed on NFS-rooted client?
Message-ID: <20101217031854.GA25106@adsl-64-142-29-25.sonic.net>
References: <20101216230622.GA23016@adsl-64-142-29-25.sonic.net> <20101217020906.GA8853@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101217020906.GA8853@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> The mount command also might be needed to update /etc/mtab if you don't have
> it linked to /proc.  Does "mount" return the expected results?

The kernel root mount is in /proc/mounts, but not in "mount"'s output.
A rootfs at / is present in both.
