From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
Date: Wed, 08 Oct 2008 10:45:08 -0400
Message-ID: <48ECC774.20809@RedHat.com>
References: <20081002154752.25618.18842.stgit@manray.1015granger.net> <20081002155412.25618.89699.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33923 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753598AbYJHOqt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 10:46:49 -0400
In-Reply-To: <20081002155412.25618.89699.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Clean up: update closedown()'s synopsis to modern C style, and move the
> function so we can remove the forward declaration.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
Committed.
