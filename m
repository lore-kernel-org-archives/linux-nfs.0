Return-Path: <SRS0=DkyH=6C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F76CC352BE
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:47:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 421C321D6C
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:47:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727944AbgDRSrD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 18 Apr 2020 14:47:03 -0400
Received: from smtprelay0006.hostedemail.com ([216.40.44.6]:56240 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725824AbgDRSrC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Apr 2020 14:47:02 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id 3F8761802EC1C;
        Sat, 18 Apr 2020 18:47:01 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: loss63_59e6ce4dc9051
X-Filterd-Recvd-Size: 2163
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf12.hostedemail.com (Postfix) with ESMTPA;
        Sat, 18 Apr 2020 18:46:57 +0000 (UTC)
Message-ID: <6bb8d99e6e56fa1622fc7238c1ae37c3b3510ded.camel@perches.com>
Subject: Re: [RFC PATCH 1/9] kernel.h: add do_empty() macro
From:   Joe Perches <joe@perches.com>
To:     Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
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
Date:   Sat, 18 Apr 2020 11:44:43 -0700
In-Reply-To: <20200418184111.13401-2-rdunlap@infradead.org>
References: <20200418184111.13401-1-rdunlap@infradead.org>
         <20200418184111.13401-2-rdunlap@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.34.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, 2020-04-18 at 11:41 -0700, Randy Dunlap wrote:
> Add the do_empty() macro to silence gcc warnings about an empty body
> following an "if" statement when -Wextra is used.
> 
> However, for debug printk calls that are being disabled, use either
> no_printk() or pr_debug() [and optionally dynamic printk debugging]
> instead.
[]
> +#define do_empty()		do { } while (0)

If this is really useful
(I think the warning is somewhat silly)

bikeshed:

I think do_nothing() is more descriptive


