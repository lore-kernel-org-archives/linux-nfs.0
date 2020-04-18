Return-Path: <SRS0=DkyH=6C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80C9AC3A5A0
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:53:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 61F93221E9
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Apr 2020 18:53:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GwZqVX1h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727853AbgDRSxI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 18 Apr 2020 14:53:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43050 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725824AbgDRSxI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Apr 2020 14:53:08 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 31F51C061A0C;
        Sat, 18 Apr 2020 11:53:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
        Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
        Subject:Sender:Reply-To:Content-ID:Content-Description;
        bh=KGgaI7/aF8gM/DdPVeh3iRDUqP5nlN3BG5/ZUjntmeQ=; b=GwZqVX1hBQ8NWcNug1tIYKrz4R
        U2IRF1+FEjojk+ZQVifHKsqFCF+H1fiJMydhq8YjDjbW9KtWGwn3olr7vK/HGNSu1WehIvKQtWosh
        BMoPriJK/H+0lffwLs5E6nvv2/JNTOwtoaK7zBEb/dn8JEcPRvepUcxaZHR8H7DkIeSlWVcUS1WWV
        CVUMlz5qooHHwL7XywdUi73jCtHRZnEwK1/5MDK68fwQFNLP2YhETImwB/mvOFWt+m48ND+munIaR
        O+7wJI5R8Vlj3BiAZo2gPs9W/wVQEXfyqPWT2fnEqJLIFpbeht4HH8Yn4gA8r97+CDZtM4p+B4qCJ
        wy6wnDqA==;
Received: from [2601:1c0:6280:3f0::19c2]
        by bombadil.infradead.org with esmtpsa (Exim 4.92.3 #3 (Red Hat Linux))
        id 1jPsaQ-0005zR-VX; Sat, 18 Apr 2020 18:53:07 +0000
Subject: Re: [PATCH 7/9] drivers/base: fix empty-body warnings in
 devcoredump.c
To:     Matthew Wilcox <willy@infradead.org>
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
References: <20200418184111.13401-1-rdunlap@infradead.org>
 <20200418184111.13401-8-rdunlap@infradead.org>
 <20200418185033.GQ5820@bombadil.infradead.org>
From:   Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b88d6f8b-e6af-7071-cefa-dc12e79116b6@infradead.org>
Date:   Sat, 18 Apr 2020 11:53:05 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.6.0
MIME-Version: 1.0
In-Reply-To: <20200418185033.GQ5820@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 4/18/20 11:50 AM, Matthew Wilcox wrote:
> On Sat, Apr 18, 2020 at 11:41:09AM -0700, Randy Dunlap wrote:
>> @@ -294,11 +295,11 @@ void dev_coredumpm(struct device *dev, s
>>  
>>  	if (sysfs_create_link(&devcd->devcd_dev.kobj, &dev->kobj,
>>  			      "failing_device"))
>> -		/* nothing - symlink will be missing */;
>> +		do_empty(); /* nothing - symlink will be missing */
>>  
>>  	if (sysfs_create_link(&dev->kobj, &devcd->devcd_dev.kobj,
>>  			      "devcoredump"))
>> -		/* nothing - symlink will be missing */;
>> +		do_empty(); /* nothing - symlink will be missing */
>>  
>>  	INIT_DELAYED_WORK(&devcd->del_wk, devcd_del);
>>  	schedule_delayed_work(&devcd->del_wk, DEVCD_TIMEOUT);
> 
> Could just remove the 'if's?
> 
> +	sysfs_create_link(&devcd->devcd_dev.kobj, &dev->kobj,
> +			"failing_device");
> 

OK.

thanks.
-- 
~Randy

