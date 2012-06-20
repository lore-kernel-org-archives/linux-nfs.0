Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34393 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab2FTSSj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2012 14:18:39 -0400
Received: by pbbrp8 with SMTP id rp8so940659pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2012 11:18:39 -0700 (PDT)
Date: Wed, 20 Jun 2012 11:18:35 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 1/3] SUNRPC: new svc_bind() routine introduced
Message-ID: <20120620181835.GA8356@kroah.com>
References: <1340050049-12880-1-git-send-email-bfields@redhat.com>
 <1340050049-12880-2-git-send-email-bfields@redhat.com>
 <20120620163427.GA6695@kroah.com>
 <20120620180928.GB24777@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120620180928.GB24777@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 20, 2012 at 02:09:29PM -0400, J. Bruce Fields wrote:
> On Wed, Jun 20, 2012 at 09:34:27AM -0700, Greg KH wrote:
> > On Mon, Jun 18, 2012 at 04:07:27PM -0400, J. Bruce Fields wrote:
> > > From: Stanislav Kinsbursky <skinsbursky@parallels.com>
> > > 
> > > commit cd96891d48a945ca2011fbeceda73813d6286195 upstream.
> > 
> > Um, no, that's not what this commit id is at all.
> 
> Whoops, sorry!  Should have been 9793f7c88.  Upstream commits on #2 and
> #3 are correct.
> 
> > Where did you get that from?  I kind of don't trust this series now,
> > care to fix these up with the correct git commit ids and resend them?
> 
> Sure, I'll resend once I get the "4/3" patch sorted out.
> 
> (That got a form rejection--I assume it was the missing upstream commit
> ID?  That's because there isn't one--3.4 requires a different fix.  But
> I can point to where the bug got fixed upstream even if it isn't the
> same.)

You need to be really specific when sending a patch that is not
upstream, detailing why it isn't, and what different fix went in
upstream, if possible.

thanks,

greg k-h
