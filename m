From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: extremely long time for exportfs to display
Date: Fri, 23 May 2008 11:20:45 -0400
Message-ID: <20080523152045.GA6276@fieldses.org>
References: <620E93B2E5CC3B46BD811165E3335B87011F8E9C@0461-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56600 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbYEWPUr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2008 11:20:47 -0400
In-Reply-To: <620E93B2E5CC3B46BD811165E3335B87011F8E9C-9/h0XwadXgnyjpQT3Si/rsM9+qvyE0V4QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 22, 2008 at 05:41:05PM -0700, Murata, Dennis wrote:
> Very recently we have seen a very serious slowdown with the exportfs
> command on a file server.  Usually the exportfs -r command or even just
> the exportfs command to display the exported directories is very quick.
> Now it can take 20 minutes to display the exported directories.
> An strace shows a lookup at /etc/hosts, from yp, and from dns.  The
> hosts lookup in /etc/nsswitch is files nis dns, so this is as expected,
> the time it is taking is not.

Have you run strace with something like -t to work out exactly where the
time is going?

--b.

> The yp slave that the server is bound to seems to be having some
> problems, could this be the issue?
> 
> Wayne
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
