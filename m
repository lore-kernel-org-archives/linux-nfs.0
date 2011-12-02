Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757078Ab1LBQYd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Dec 2011 11:24:33 -0500
Date: Fri, 2 Dec 2011 11:24:31 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
Message-ID: <20111202162431.GC14393@fieldses.org>
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
 <4ED7EBFF.6030706@RedHat.com>
 <4ED7F7B9.2090205@netapp.com>
 <4ED8318B.5040400@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED8318B.5040400@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 09:01:47PM -0500, Steve Dickson wrote:
> 
> 
> On 12/01/2011 04:55 PM, Bryan Schumaker wrote:
> > On Thu Dec  1 16:05:03 2011, Steve Dickson wrote:
> >> Now what is the motivating reason behind this re-architecture
> >> other than making the upstream kernel literally impossible to 
> >> back port to older kernels?? 
> >>
> > I wasn't thinking about backporting when I did this... is there a 
> > better way to do this that wouldn't make it a pain to backport?
> Yeah... Don't do it! 8-) Major architectural changes always destroy
> any all chances of clean back ports... That's why they are generally 
> done on major releases... the when 3.X was released... 

There was nothing special about 3.0 other than the name; it could just
as easily have been called 2.6.40.

But anyway I don't see the big problem for backports.  Probably git can
deal with the renames automatically, and even if it can't the fixup is
going to be pretty obvious.  This isn't like the xdr changes that
touched so many lines, it's mainly just a simple rename.

--b.
