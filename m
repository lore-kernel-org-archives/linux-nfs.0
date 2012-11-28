Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm11-vm1.bullet.mail.sg3.yahoo.com ([106.10.148.240]:26946 "EHLO
	nm11-vm1.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699Ab2K1FId convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 00:08:33 -0500
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com> <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com> <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com> <20121125144816.GA31110@fieldses.org> <1353982692.94013.YahooMailNeo@web190603.mail.sg3.yahoo.com> <20121127023927.GB18930@fieldses.org> <1354001852.79169.YahooMailNeo@web190602.mail.sg3.yahoo.com> <20121127142409.GA28131@fieldses.org>
Message-ID: <1354078956.45522.YahooMailNeo@web190604.mail.sg3.yahoo.com>
Date: Wed, 28 Nov 2012 13:02:36 +0800 (SGT)
From: Kks Kbase <kks.kbase@yahoo.in>
Reply-To: Kks Kbase <kks.kbase@yahoo.in>
Subject: Re: NFS exportfs options
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <20121127142409.GA28131@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry I am unable to get the exact information from the man page.

If I use no_root_squash then root only can do anything but other users still can't.

Can you let me know how can I give write permission to other users?



----- Original Message -----
From: J. Bruce Fields <bfields@fieldses.org>
To: Kks Kbase <kks.kbase@yahoo.in>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Sent: Tuesday, 27 November 2012 7:54 PM
Subject: Re: NFS exportfs options

On Tue, Nov 27, 2012 at 03:37:32PM +0800, Kks Kbase wrote:
> I have tried to all_squash but no luck. Even I have tried to access it as root itself which have the same issue,

all_squash won't help, you need to use no_root_squash or write
permissions to other than root.  Please read the relevant parts of the
export man page carefully.

--b.
