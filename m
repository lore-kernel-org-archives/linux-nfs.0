From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils] Give useful error if mount.nfs not installed
 setuid.
Date: Thu, 08 May 2008 05:21:00 -0400
Message-ID: <4822C5FC.8020203@RedHat.com>
References: <18466.32444.577468.951202@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757086AbYEHJ0Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 05:26:25 -0400
In-Reply-To: <18466.32444.577468.951202-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> If mount.nfs is not installed setuid, an attempt to perform a "user"
> or "users" mount will fail with a fairly obscure error message,
> typically about getting "permission denied" from the server.
> 
> This patch gives a more helpful message in that case.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... thanks...

steved.

