From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/15] Fixes for nfs-utils-1.2.4
Date: Thu, 14 Oct 2010 10:37:37 -0400
Message-ID: <4CB715B1.40705@RedHat.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157Ab0JNOhl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:37:41 -0400
In-Reply-To: <20101010234836.6667.4057.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/10/2010 08:04 PM, Chuck Lever wrote:
> Steve-
> 
> Here are fifteen patches which address several mount and mountd bugs
> and correct other minor problems in nfs-utils-1.2.3.  Now that the
> bake-a-thon event has passed, folks should have some spare moments to
> review these.
> 
> This series includes the final version of the patch that addresses the
> "mountd -p <port> does not work" issue.
> 
> The series does not include a patch to address the "remount erases a
> mount point's version setting" issue.  The remount problem is not a
> 1.2.3 regression, it's been around for a very long time.  I'm still
> exploring solutions.
> 
> These patches are also available in my nfs-utils git repo on
> git.linux-nfs.org.
All 16 patches (including Neil's patch) have been committed.

steved.

