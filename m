Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:46143 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3JFGKs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 02:10:48 -0400
Date: Sat, 5 Oct 2013 16:46:12 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Marc Meledandri <m.meledandri@gmail.com>
Subject: Re: [PATCH] nfsd4: fix leak of inode reference on delegation failure
Message-ID: <20131005234611.GD18223@kroah.com>
References: <20131001144250.GJ26382@fieldses.org>
 <20131002140331.GB14808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002140331.GB14808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 10:03:32AM -0400, J. Bruce Fields wrote:
> Whoops, apologies, this requires a little fixing up to backport.  Ignore
> for now.

Even for 3.11?  It seems to build there just fine.

thanks,

greg k-h
