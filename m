Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60568 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570Ab1G0QHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 12:07:53 -0400
Date: Wed, 27 Jul 2011 12:07:53 -0400
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727160752.GC974@fieldses.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 09:54:09AM -0400, Justin Piszcz wrote:
> Hi,
> 
> Kernel 2.6.30 on client.
> Kernel 2.6.28 on server.
> 
> p34 kernel: [92223.918892] NFS: directory motion/cam2 contains a
> readdir loop.  Please contact your server vendor.  Offending cookie: 10272

What filesystem on the server are you exporting?

> In the past I used NFS to push -> imagery -> NFS server.
> Now I've flipped it so I am storing the images locally and viewing
> them remotely, what causes this?

Sorry, I don't understand what you mean.

--b.
