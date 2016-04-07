Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59326 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756449AbcDGSOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 14:14:24 -0400
Date: Thu, 7 Apr 2016 14:14:22 -0400
To: YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Sometimes all the applications using sqlite do not work correctly
Message-ID: <20160407181422.GB30676@fieldses.org>
References: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 07, 2016 at 01:09:27AM +0200, YuGiOhJCJ Mailing-List wrote:
> Hello,
> 
> I am using nfs-utils-1.2.8 and sqlite-3.7.17 on Slackware 14.1.
> Sometimes, all the applications using sqlite do not work correctly.
> 
> These applications are:
>  * mozilla-firefox-44.0
>  * mumble-1.2.8
>  * xmoto-0.5.11
> 
> On mozilla-firefox, my bookmarks menu is empty.
> On mumble, my favorite server list is empty.
> On xmoto, the game could not run.
> 
> All these applications at the same time do not work and I need to restart the NFS server in order to be able to use these programs.

So when the problem happens, restarting the server fixes the problem?

> I don't know what could be the cause but I know that I have recently upgraded a lot of programs on my operating system (binutils-2.26, gcc-5.3.0, ...).

It's probably the kernel version that's most important.  So it might be
interesting to know what your kernel version was before and what it is
now.

Also: what's your NFS server?  Was it upgraded at the same time, or was
only your client upgraded?

--b.

> I am using NFS since many years (at least 4) and I have never get troubles with my applications using sqlite.
> 
> So, I am wondering what happens.
> 
> Should I rebuild nfs-utils?
> 
> Thank you.
> Best regards.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
