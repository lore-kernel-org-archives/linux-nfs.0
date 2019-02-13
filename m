Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E333CC282C2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 05:36:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B867A222BB
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 05:36:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726432AbfBMFgx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 00:36:53 -0500
Received: from mx1.redhat.com ([209.132.183.28]:57336 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726418AbfBMFgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Feb 2019 00:36:53 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8ADECC058CB0;
        Wed, 13 Feb 2019 05:36:53 +0000 (UTC)
Received: from sh-el5.eng.rdu2.redhat.com (sh-el5.eng.rdu2.redhat.com [10.10.160.68])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 5F7A660BE8;
        Wed, 13 Feb 2019 05:36:53 +0000 (UTC)
Received: from sh-el5.eng.rdu2.redhat.com (localhost.localdomain [127.0.0.1])
        by sh-el5.eng.rdu2.redhat.com (8.13.8/8.13.8) with ESMTP id x1D5aqYk012284;
        Wed, 13 Feb 2019 00:36:52 -0500
Received: (from xzhou@localhost)
        by sh-el5.eng.rdu2.redhat.com (8.13.8/8.13.8/Submit) id x1D5aqiL012283;
        Wed, 13 Feb 2019 00:36:52 -0500
Date:   Wed, 13 Feb 2019 00:36:52 -0500
From:   Murphy Zhou <jencce.kernel@gmail.com>
To:     Greg KH <gregkh@linuxfoundation.org>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [v5.0-rc3 regression] Oops when starting nfs service
Message-ID: <20190213053652.GA12243@sh-el5.eng.rdu2.redhat.com>
References: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com> <20190212194413.GC3471@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212194413.GC3471@kroah.com>
User-Agent: Mutt/1.4.2.2i
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 13 Feb 2019 05:36:53 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Greg,

Your patch works fine for me. Thanks!

On Tue, Feb 12, 2019 at 08:44:13PM +0100, Greg KH wrote:
> On Tue, Feb 12, 2019 at 11:21:57AM -0500, Murphy Zhou wrote:
> > Hi,
> > 
> > Starting nfs-server service can crash the kernel since
> > commit ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> > Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date:   Wed Jan 23 11:28:14 2019 +0100
> > 
> >     debugfs: return error values, not NULL
> > 
> > # git describe ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> > v5.0-rc2-3-gff9fb72bc077
> > 
> 
> Be careful with 'git describe', you showed what I applied that patch
> against, not what release it showed up in.
> 
> This really showed up in 5.0-rc6:
> 
> $ git describe --contains ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> v5.0-rc6~21^2~3

Thanks very much for the tip! I forgot about this, so it should be
rc6 regression.

Thanks,
Murphy

> 
> thanks,
> 
> greg k-h
