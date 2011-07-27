Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:53223 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755080Ab1G0RAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 13:00:14 -0400
From: Ruediger Meier <sweet_f_a@gmx.de>
To: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Date: Wed, 27 Jul 2011 19:00:10 +0200
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <4E303F6F.8010706@netapp.com>
In-Reply-To: <4E303F6F.8010706@netapp.com>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201107271900.11091.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 27 July 2011, Bryan Schumaker wrote:
> On 07/27/2011 12:28 PM, Justin Piszcz wrote:
> > On Wed, 27 Jul 2011, J. Bruce Fields wrote:
> >>
> >> What filesystem on the server are you exporting?
> >
> > xfs.
> > /dev/sda1 on / type xfs (rw,noatime)
> >
> > Nothing special, thoughts?
>
> Are there a lot of files in the directory you're exporting?  It looks
> like cookie 10272 is mapped to multiple files.

I thought xfs is immune to readdir loops!?
Is your export directory really located directly within / on /dev/sda1?

cu,
Rudi
