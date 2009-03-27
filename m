Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37333 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764656AbZC0Xq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 19:46:27 -0400
Date: Fri, 27 Mar 2009 19:46:25 -0400
To: Greg Banks <gnb@sgi.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Document /proc/fs/nfsd/pool_stats
Message-ID: <20090327234625.GF18222@fieldses.org>
References: <49CB2487.9090602@sgi.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <49CB2487.9090602@sgi.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 26, 2009 at 05:45:27PM +1100, Greg Banks wrote:
> Document the format and semantics of the /proc/fs/nfsd/pool_stats file.

Thanks, that's very helpful--applied.

> +Kernel NFS Server Statistics
> +============================
> +
> +This document describes the format and semantics of the statistics
> +which the kernel NFS server makes available to userspace.  These
> +statistics are available in several text form pseudo files, each of
> +which is described separately below.
...
> +/proc/fs/nfsd/pool_stats
> +------------------------
...
> +More
> +----
> +Descriptions of the other statistics file should go here.

Hm, OK.  Volunteers welcomed....

--b.
