From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: fix endptr check in closeall (try #4)
Date: Mon, 22 Jun 2009 12:02:53 -0400
Message-ID: <4A3FAB2D.7070508@RedHat.com>
References: <1244116387-19827-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
	trond.myklebust@fys.uio.no
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45194 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757146AbZFVQGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2009 12:06:05 -0400
In-Reply-To: <1244116387-19827-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> The closeall function is broken in such a way that it almost never
> closes any file descriptors. It's calling strtol on the text
> representation of the file descriptor, and then checking to see if the
> value of *endptr is not '\0' before trying to close the file. This check
> is wrong.
> 
> When strtol returns an endptr that points to a NULL byte, that indicates
> that the conversion was completely successful. I believe this check
> should instead be requiring that endptr is pointing to '\0' before
> closing the fd.
> 
> Also, fix up the function to check for conversion errors from strtol. If
> one occurs, just skip the close on that entry.
> 
> Finally, as Trond pointed out, it's unlikely that readdir will return a
> blank string in d_name but that situation wouldn't be detected by the
> current code. This patch adds such a check and skips the close if it
> occurs.
> 
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
Committed....

steved.
