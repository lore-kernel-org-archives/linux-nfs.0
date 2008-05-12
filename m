From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] text-based mounts should check statd if "lock" is specified
Date: Tue, 13 May 2008 09:18:22 +1000
Message-ID: <18472.53310.76979.734043@notabene.brown>
References: <20080512211329.7250.98590.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:56466 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894AbYELXSa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2008 19:18:30 -0400
In-Reply-To: message from Chuck Lever on Monday May 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday May 12, chucklever@gmail.com wrote:
> From: Neil Brown <neilb@suse.de>
> 
> Make the text-based mount path check whether statd is running if the "lock"
> option is in effect.  This echoes similar logic in the legacy mount path.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> I tried out your patch today, and it caused mounts to fail silently.
> 
> As part of the fix, I reversed the return codes for verify_lock_option to
> match the other helpers, and added a documenting comment.
> 
> Does this look OK?


Yes,  an all-round improvement.
Thanks.
NeilBrown
