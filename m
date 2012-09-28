Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59757 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab2I1AOI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 20:14:08 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so4328254pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2012 17:14:08 -0700 (PDT)
Date: Thu, 27 Sep 2012 17:13:57 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@redhat.com, viro@zeniv.linux.org.uk,
        jbottomley@parallels.com
Subject: Re: [PATCH 0/2] nfsd: backport fixes for 3.5 kernel
Message-ID: <20120928001357.GK29949@kroah.com>
References: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
 <20120917150105.GJ30673@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120917150105.GJ30673@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2012 at 11:01:05AM -0400, J. Bruce Fields wrote:
> On Fri, Sep 14, 2012 at 12:25:17PM +0400, Stanislav Kinsbursky wrote:
> > Hello.
> > These two patches fixes existent NULL pointer dereference problem in 3.5.3
> > kernel in case of some error occured during NFSd service start.
> > 
> > Upstream commits:
> > 19f7e2ca44dfc3c1b3f499fc46801f98d403500f 
> > 57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d
> 
> Thanks.  Ack to including both of these in stable releases.

Now applied, also to the 3.4.y stable series.

greg k-h
