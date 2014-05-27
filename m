Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44435 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbaE0Uz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 16:55:27 -0400
Date: Tue, 27 May 2014 16:55:27 -0400
To: Felix Miata <mrmazda@earthlink.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: system updating routinely umounts "manual" nfs mounts
Message-ID: <20140527205527.GC32160@fieldses.org>
References: <53823B52.2080201@earthlink.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53823B52.2080201@earthlink.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 25, 2014 at 02:49:54PM -0400, Felix Miata wrote:
> This has been happening here for several months or more in devel
> distro versions Factory and IIRC Cauldron and Rawhide.
> 
> Maybe others' manual nfs mounts are more "manual" than mine are.
> Mine are actually a group of noauto fstab entries I enable via
> script when I want them active. All of my installations are on real
> x86 hardware, some 32 and others 64 bit. I'm guessing what's going
> on is systemd updates syncing /proc/mounts to fstab, oblivious to
> the manual post-init mount processes having taken place, but this
> certainly could be nfs evolutionary fallout or something else I know
> nothing about. Is this happening to others? Expected? My search of
> nfs component @bugzilla.kernel.org produced nothing on apparent
> point.

The kernel certainly isn't going to unmount things for you like this, so
this is a question for the distro or systemd maintainers or something.

--b.
