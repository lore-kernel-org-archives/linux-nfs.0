From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] NFS: Fix the notifications when renaming onto
	an existing file
Date: Tue, 12 May 2009 15:31:05 -0700
Message-ID: <20090512223105.GA16679@kroah.com>
References: <20090512222420.6972.25308.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57547 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063AbZELWe1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 18:34:27 -0400
In-Reply-To: <20090512222420.6972.25308.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 12, 2009 at 06:24:20PM -0400, Trond Myklebust wrote:
> NFS appears to be returning an unnecessary "delete" notification when
> we're doing an atomic rename. See
> 
>   http://bugzilla.gnome.org/show_bug.cgi?id=575684
> 
> The fix is to get rid of the redundant call to d_delete().
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> Please apply to 2.6.27 - 2.6.29 stable series...

Is this already in Linus's tree?  If so, what is the git commit id?

thanks,

greg k-h
