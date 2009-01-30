From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Address kernel bugzilla 12256
Date: Fri, 30 Jan 2009 15:21:12 -0500
Message-ID: <20090130202112.GF31166@fieldses.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53439 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZA3UVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:21:11 -0500
In-Reply-To: <20090130200021.22301.22618.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 03:10:32PM -0500, Chuck Lever wrote:
> Updated patch series to remove the SUNRPC_REGISTER_V4 kernel build
> option.  These address kernel bugzilla 12256 ("RPC: failed to contact
> local rpcbind server (errno 5)." if CONFIG_SUNRPC_REGISTER_V4 is set
> to Y").  Please include them in your for-2.6.30 branch, replacing
> any previous version of this patch series.
> 
> There may be some problems applying this patch set to linux-next, as
> that may have recent patches that split up fs/Kconfig.

Actually, those patches are in mainline (and my for-2.6.30 branch);
would you like to rebase?  It should be trivial.

--b.
