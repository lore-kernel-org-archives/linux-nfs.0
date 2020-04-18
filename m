Return-Path: <SRS0=DkyH=6C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA87DC352BE
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:57:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A457B221E9
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:57:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727862AbgDRS5Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 18 Apr 2020 14:57:25 -0400
Received: from smtprelay0003.hostedemail.com ([216.40.44.3]:57188 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726086AbgDRS5Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Apr 2020 14:57:24 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id AB7DD1801C62B;
        Sat, 18 Apr 2020 18:57:23 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: oven32_22ec242d00d03
X-Filterd-Recvd-Size: 2832
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf13.hostedemail.com (Postfix) with ESMTPA;
        Sat, 18 Apr 2020 18:57:19 +0000 (UTC)
Message-ID: <d018321b0f281ff29efb04dd1496c8e6499812fb.camel@perches.com>
Subject: Re: [PATCH 7/9] drivers/base: fix empty-body warnings in
 devcoredump.c
From:   Joe Perches <joe@perches.com>
To:     Randy Dunlap <rdunlap@infradead.org>,
        Matthew Wilcox <willy@infradead.org>
Cc:     linux-kernel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        linux-input@vger.kernel.org, Jaroslav Kysela <perex@perex.cz>,
        Takashi Iwai <tiwai@suse.com>, alsa-devel@alsa-project.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Johannes Berg <johannes@sipsolutions.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Vishal Verma <vishal.l.verma@intel.com>,
        Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
        Zzy Wysm <zzy@zzywysm.com>
Date:   Sat, 18 Apr 2020 11:55:05 -0700
In-Reply-To: <b88d6f8b-e6af-7071-cefa-dc12e79116b6@infradead.org>
References: <20200418184111.13401-1-rdunlap@infradead.org>
         <20200418184111.13401-8-rdunlap@infradead.org>
         <20200418185033.GQ5820@bombadil.infradead.org>
         <b88d6f8b-e6af-7071-cefa-dc12e79116b6@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.34.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, 2020-04-18 at 11:53 -0700, Randy Dunlap wrote:
> On 4/18/20 11:50 AM, Matthew Wilcox wrote:
> > On Sat, Apr 18, 2020 at 11:41:09AM -0700, Randy Dunlap wrote:
> > > @@ -294,11 +295,11 @@ void dev_coredumpm(struct device *dev, s
> > >  
> > >  	if (sysfs_create_link(&devcd->devcd_dev.kobj, &dev->kobj,
> > >  			      "failing_device"))
> > > -		/* nothing - symlink will be missing */;
> > > +		do_empty(); /* nothing - symlink will be missing */
> > >  
> > >  	if (sysfs_create_link(&dev->kobj, &devcd->devcd_dev.kobj,
> > >  			      "devcoredump"))
> > > -		/* nothing - symlink will be missing */;
> > > +		do_empty(); /* nothing - symlink will be missing */
> > >  
> > >  	INIT_DELAYED_WORK(&devcd->del_wk, devcd_del);
> > >  	schedule_delayed_work(&devcd->del_wk, DEVCD_TIMEOUT);
> > 
> > Could just remove the 'if's?
> > 
> > +	sysfs_create_link(&devcd->devcd_dev.kobj, &dev->kobj,
> > +			"failing_device");
> > 
> 
> OK.

sysfs_create_link is __must_check


