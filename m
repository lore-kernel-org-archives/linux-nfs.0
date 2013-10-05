Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:46134 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab3JFGKq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 02:10:46 -0400
Date: Sat, 5 Oct 2013 16:45:23 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Marc Meledandri <m.meledandri@gmail.com>
Subject: Re: [PATCH] nfsd4: fix leak of inode reference on delegation failure
Message-ID: <20131005234523.GC18223@kroah.com>
References: <20131001144250.GJ26382@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131001144250.GJ26382@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 10:42:50AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> commit bf7bd3e98be5c74813bee6ad496139fb0a011b3b upstream, for >= 3.10.

This doesn't apply at all to 3.10, but does to 3.11.  If you want it in
3.10, can you provide a backport that works?

thanks,

greg k-h
