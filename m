From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/10] RFC: NFS-related fs/Kconfig updates
Date: Thu, 7 Feb 2008 18:22:50 -0500
Message-ID: <20080207232250.GE25374@fieldses.org>
References: <20080205180726.32229.35186.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:35506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757443AbYBGXWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 18:22:54 -0500
In-Reply-To: <20080205180726.32229.35186.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 05, 2008 at 01:08:28PM -0500, Chuck Lever wrote:
> Another pass at cleaning up the NFS and NFSD entries in fs/Kconfig.
> 
> Comments / suggestions?

By the way, we've got another config-related nit here:

	http://bugzilla.linux-nfs.org/show_bug.cgi?id=156

You can build lockd without CONFIG_SYSCTL set, but then the module will
fail to load.

--b.
