Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650Ab3GIQ62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 12:58:28 -0400
Date: Tue, 9 Jul 2013 12:58:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: support minorversion 1 by default
Message-ID: <20130709165827.GE8281@fieldses.org>
References: <20130709031928.GN29071@fieldses.org>
 <20130709150657.GB8281@fieldses.org>
 <51DC32C8.6080504@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51DC32C8.6080504@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 11:56:56AM -0400, Steve Dickson wrote:
> 
> 
> On 09/07/13 11:06, J. Bruce Fields wrote:
> > On Mon, Jul 08, 2013 at 11:19:28PM -0400, J. Bruce Fields wrote:
> >> > From: "J. Bruce Fields" <bfields@redhat.com>
> >> > 
> >> > We now have minimal minorversion 1 support; turn it on by default.
> >> > 
> >> > This can still be turned off with "echo -4.1 >/proc/fs/nfsd/versions".
> > I intend this for 3.11, since as far as I can tell we're up to spec and
> > the 4.1-specific bugs I know about have been fixed.
> Ok... Its on my TODO list but I'll wait a bit until 3.11 hits
> the street... 

I don't think there's anything for you to do here.

--b.
