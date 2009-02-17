From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support IPv6 in umount.nfs command
Date: Tue, 17 Feb 2009 16:27:45 -0500
Message-ID: <499B2BD1.2030306@RedHat.com>
References: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51066 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbZBQVaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2009 16:30:24 -0500
In-Reply-To: <20090128225938.21484.82096.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> The first patch in this series is a simple update to .gitignore.
> 
> The following patches implement support for IPv6 addresses in the
> umount.nfs command.
> 
> I think it would be prudent to stop after this set, and let the
> extensive changes I've submitted so far soak a little bit.  These
> probably won't see wide-ranging use until after the next release of
> nfs-utils, I'm guessing.
> 
> Given the problems that arose after the last nfs-utils release, I
> think this might be a good stopping point until after the next
> nfs-utils release.  By then, I might even have full support completed
> for IPv6 in rpc.statd and sm-notify.
> 
Committed...

steved.
