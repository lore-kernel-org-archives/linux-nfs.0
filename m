Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37484 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719Ab3JFPJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Oct 2013 11:09:36 -0400
Date: Sun, 6 Oct 2013 11:09:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Marc Meledandri <m.meledandri@gmail.com>
Subject: Re: [PATCH] nfsd4: fix leak of inode reference on delegation failure
Message-ID: <20131006150935.GA3695@fieldses.org>
References: <20131001144250.GJ26382@fieldses.org>
 <20131002140331.GB14808@fieldses.org>
 <20131005234611.GD18223@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131005234611.GD18223@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 05, 2013 at 04:46:12PM -0700, Greg KH wrote:
> On Wed, Oct 02, 2013 at 10:03:32AM -0400, J. Bruce Fields wrote:
> > Whoops, apologies, this requires a little fixing up to backport.  Ignore
> > for now.
> 
> Even for 3.11?  It seems to build there just fine.

Please do apply for 3.11, thanks for noticing that.

Then if/when this gets backported to 3.10 we'll send that separately.

Apologies for the confusion.

--b.
