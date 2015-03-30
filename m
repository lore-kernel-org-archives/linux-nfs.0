Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:47041 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbbC3PQn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 11:16:43 -0400
Date: Mon, 30 Mar 2015 17:16:38 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] debugfs: debugfs_create_* shouldn't be checking
 permissions
Message-ID: <20150330151638.GA13616@kroah.com>
References: <20150330142310.GB6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150330142310.GB6901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 10:23:10AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions

Side-note, why are you putting the Subject: again here in the body of
the patch?

thanks,

greg k-h
