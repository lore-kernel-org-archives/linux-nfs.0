From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mountd: change "unknown host" error message to "unmatched
 host"
Date: Mon, 29 Sep 2008 10:21:01 -0400
Message-ID: <48E0E44D.7090207@RedHat.com>
References: <1222690298-20802-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37295 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbYI2OWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 10:22:25 -0400
In-Reply-To: <1222690298-20802-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> I've had a few users mention that they find this message confusing:
> 
>      mount request from unknown host 10.11.14.99 for /export
> 
> The hosts are listed in DNS with proper reverse records, so the reason
> why the host is "unknown" isn't clear. This patch just changes the
> wording of this error to hopefully make it more clear why the mount
> request was rejected. This also makes this error message use a format
> more similar to the other error messages in auth_authenticate().
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Committed.

steved.
