Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:34173 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbaEAWCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 18:02:53 -0400
Date: Thu, 1 May 2014 15:03:50 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Johan Hovold <jhovold@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Mark Lord <mlord@pobox.com>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [stable] linux-3.14 nfsd regression
Message-ID: <20140501220350.GC29518@kroah.com>
References: <20140501084045.GA4766@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140501084045.GA4766@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2014 at 10:40:45AM +0200, Johan Hovold wrote:
> Hi Greg,
> 
> I noticed that v3.14 broke my development system which relies on nfsroot
> for embedded targets, but soon found Bruce's fix (which has now been in
> Linus' tree for a while):
> 
> 	082f31a2169b ("nfsd: revert v2 half of "nfsd: don't return high
> 		       mode bits")
> 
> The fix did not make it into v3.14.2 (and I didn't find it in your
> stable queue), so I thought I'd send a reminder.

It's part of my huge "patches to apply to stable" queue that I'm slowly
working through.  So don't worry, it will make it there soon.

thanks,

greg k-h
