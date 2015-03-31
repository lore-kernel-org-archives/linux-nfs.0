Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:47752 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbbCaO0p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 10:26:45 -0400
Date: Tue, 31 Mar 2015 16:26:41 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, trond.myklebust@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: make debugfs file creation failure non-fatal
Message-ID: <20150331142641.GA9961@kroah.com>
References: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>
 <20150330234753.GG6901@fieldses.org>
 <20150331140916.GJ6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150331140916.GJ6901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 10:09:16AM -0400, J. Bruce Fields wrote:
> On Mon, Mar 30, 2015 at 07:47:53PM -0400, J. Bruce Fields wrote:
> > ACK.--b.
> 
> But note the result after this is that the debugfs directories will
> always miss gss-proxy clients on selinux-enforcing systems.  That could
> be really confusing.

So, you shouldn't be relying on debugfs :)

> So we should still fix debugfs's permission checking.  It doesn't make
> sense to me as is.

I don't really understand what the problem is here.  Is selinux
preventing some debugfs files to be created?  If so, great, it's allowed
to do that, go fix up your selinux config files to not do that.
Otherwise, to go around selinux/LSM seems like a bad idea for debugfs to
be doing, don't you think?

thanks,

greg k-h
