From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils patches
Date: Wed, 17 Dec 2008 15:24:09 -0500
Message-ID: <49495FE9.1030209@RedHat.com>
References: <20081211182820.6882.20716.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44497 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169AbYLQU0X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 15:26:23 -0500
In-Reply-To: <20081211182820.6882.20716.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Three more patches for nfs-utils in the IPv6 series.
> 
> The first is a minor bug fix for the sm-notify command, since we've
> been focusing on that area recently.  It fixes a use-after-free.
> 
> The next two don't add new IPv6 functionality, but are prerequisites.
> The first adds a new string parsing API that specifically handles
> mount options that take a numeric value.  The second changes the
> handler for one such option (retry= in this case) to use the new API.
> 
> Subsequent patches will make use of this new API to handle mount
> options that are used to fill in pmap structs.
> 
> ---
> 
> Chuck Lever (3):
>       text-based mount command: use po_get_numeric() for handling retry=
>       text-based mount command: add function to parse numeric mount options
>       sm-notify command: fix a use-after-free bug
Committed.... 

steved.
