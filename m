From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] struct pmap stuffing
Date: Tue, 27 Jan 2009 18:02:21 -0500
Message-ID: <497F927D.1040000@RedHat.com>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50493 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbZA0XEu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jan 2009 18:04:50 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Happy New Year.  Continuing with the IPv6 patch series for the NFS
> mount command, I bring you five more patches.
> 
> These introduce a new facility for converting a set of NFS mount
> options into a properly filled-in struct pmap, ripe for passing into
> everyday existing functions like nfs_getport().
> 
> The final patches in today's set use this new facility to correct a
> number of problems with the text-based mount command's NFS version
> detection and fallback logic.
> 
> The next set of patches will use this new facility to bring IPv6
> support to umount.nfs.
> 
> If you have some unit tests for mount.nfs handling version fallback
> and/or operating in an environment that does not have an accessible
> portmapper on the server, please try them with this series applied.
> 
> ---
> 
Committed and tested... 

steved.
