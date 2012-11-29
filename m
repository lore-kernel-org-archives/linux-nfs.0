Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517Ab2K2OHq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 09:07:46 -0500
Date: Thu, 29 Nov 2012 09:07:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kks Kbase <kks.kbase@yahoo.in>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS exportfs options
Message-ID: <20121129140745.GA29524@fieldses.org>
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com>
 <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com>
 <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com>
 <20121125144816.GA31110@fieldses.org>
 <1353982692.94013.YahooMailNeo@web190603.mail.sg3.yahoo.com>
 <20121127023927.GB18930@fieldses.org>
 <1354001852.79169.YahooMailNeo@web190602.mail.sg3.yahoo.com>
 <20121127142409.GA28131@fieldses.org>
 <1354078956.45522.YahooMailNeo@web190604.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1354078956.45522.YahooMailNeo@web190604.mail.sg3.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 01:02:36PM +0800, Kks Kbase wrote:
> Sorry I am unable to get the exact information from the man page.
> 
> If I use no_root_squash then root only can do anything but other users still can't.
> 
> Can you let me know how can I give write permission to other users?

See "man chmod", or "info file permissions"; or

	http://www.tuxfiles.org/linuxhelp/filepermissions.html

looks like one possible good starting point (just the first google hit
for "linux permissions").

This isn't really an nfs question.

--b.

> 
> 
> 
> ----- Original Message -----
> From: J. Bruce Fields <bfields@fieldses.org>
> To: Kks Kbase <kks.kbase@yahoo.in>
> Cc: Linux NFS <linux-nfs@vger.kernel.org>
> Sent: Tuesday, 27 November 2012 7:54 PM
> Subject: Re: NFS exportfs options
> 
> On Tue, Nov 27, 2012 at 03:37:32PM +0800, Kks Kbase wrote:
> > I have tried to all_squash but no luck. Even I have tried to access it as root itself which have the same issue,
> 
> all_squash won't help, you need to use no_root_squash or write
> permissions to other than root.  Please read the relevant parts of the
> export man page carefully.
> 
> --b.
