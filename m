Return-Path: <SRS0=DkyH=6C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73381C352BE
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 19:54:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 498E821BE5
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 19:54:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728238AbgDRTyN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 18 Apr 2020 15:54:13 -0400
Received: from netrider.rowland.org ([192.131.102.5]:43585 "HELO
        netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1728228AbgDRTyN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Apr 2020 15:54:13 -0400
Received: (qmail 9694 invoked by uid 500); 18 Apr 2020 15:54:12 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 18 Apr 2020 15:54:12 -0400
Date:   Sat, 18 Apr 2020 15:54:12 -0400 (EDT)
From:   Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@netrider.rowland.org
To:     Matthew Wilcox <willy@infradead.org>
cc:     Randy Dunlap <rdunlap@infradead.org>,
        <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        <linux-fsdevel@vger.kernel.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        <linux-input@vger.kernel.org>, Jaroslav Kysela <perex@perex.cz>,
        Takashi Iwai <tiwai@suse.com>, <alsa-devel@alsa-project.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        <linux-usb@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Vishal Verma <vishal.l.verma@intel.com>,
        Dave Jiang <dave.jiang@intel.com>, <linux-nvdimm@lists.01.org>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        <linux-scsi@vger.kernel.org>, <target-devel@vger.kernel.org>,
        Zzy Wysm <zzy@zzywysm.com>
Subject: Re: [PATCH 5/9] usb: fix empty-body warning in sysfs.c
In-Reply-To: <20200418184409.GP5820@bombadil.infradead.org>
Message-ID: <Pine.LNX.4.44L0.2004181549020.8036-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, 18 Apr 2020, Matthew Wilcox wrote:

> On Sat, Apr 18, 2020 at 11:41:07AM -0700, Randy Dunlap wrote:
> > +++ linux-next-20200327/drivers/usb/core/sysfs.c
> > @@ -1263,7 +1263,7 @@ void usb_create_sysfs_intf_files(struct
> >  	if (!alt->string && !(udev->quirks & USB_QUIRK_CONFIG_INTF_STRINGS))
> >  		alt->string = usb_cache_string(udev, alt->desc.iInterface);
> >  	if (alt->string && device_create_file(&intf->dev, &dev_attr_interface))
> > -		;	/* We don't actually care if the function fails. */
> > +		do_empty(); /* We don't actually care if the function fails. */
> >  	intf->sysfs_files_created = 1;
> >  }
> 
> Why not just?
> 
> +	if (alt->string)
> +		device_create_file(&intf->dev, &dev_attr_interface);

This is another __must_check function call.

The reason we don't care if the call fails is because the file
being created holds the USB interface string descriptor, something
which is purely informational and hardly ever gets set (and no doubt
gets used even less often).

Is this another situation where the comment should be expanded and the 
code modified to include a useless test and cast-to-void?

Or should device_create_file() not be __must_check after all?

Greg?

Alan Stern

