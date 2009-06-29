From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mydaemon: remove closeall() calls from mydaemon()
Date: Mon, 29 Jun 2009 10:56:42 -0400
Message-ID: <4A48D62A.5080302@RedHat.com>
References: <1245700238-3755-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43841 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbZF2O7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jun 2009 10:59:53 -0400
In-Reply-To: <1245700238-3755-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> idmapd and svcgssd have a mydaemon() routine that uses closeall() to
> close file descriptors. Unfortunately, they aren't using it correctly
> and it ends up closing the pipe that the child process uses to talk to
> its parent.
> 
> Fix this by not using closeall() in this routine and instead, just close
> the file descriptors that we know need to be closed. If /dev/null can't
> be opened for some reason, then just have the child exit with a non-zero
> error.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Committed...

steved.

