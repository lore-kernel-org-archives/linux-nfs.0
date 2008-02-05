From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 05 Feb 2008 11:19:21 +1100
Message-ID: <47A7AB89.7020709@melbourne.sgi.com>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:58593 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754908AbYBEAMy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 19:12:54 -0500
In-Reply-To: <20080205000442.18602.29035.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> TCP support in the Linux NFS server is stable enough that we can leave it
> on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and defaults to
> "Y" anyway.
>
> A run-time switch might be more appropriate if people feel they would like
> to disable NFSD's TCP support.
>
>   
Looks good.

Actually, I'd be inclined to go one step further and set UDP support
off by default.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

