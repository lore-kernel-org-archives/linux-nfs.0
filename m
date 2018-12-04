Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15380C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:24:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C2AF92081B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:24:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Rbb9ofTQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2AF92081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726152AbeLDPYi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 10:24:38 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:53300 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725910AbeLDPYh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 10:24:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=4YoeMDDYkyCMOWutQl7+L7v9j4Qk9avJxmcFLaEfa7A=; b=Rbb9ofTQ5PByo79lYn8MJgspE
        BSLnR9NxRarUdWCjVAnNBbYMfCLgmONJtqzFp7NagZNs2EimqXKnhzwygQtQn3EXoR9cytHs2S5MJ
        fpSk9gbucmOWcPn3rMaxREkRW93TM3Fk0hM1ozC7J6ujHesUWbcAmaZN4i8X2o2YRWl+agJozY+q+
        tBCmSlRMbhRdqP3tZ0fwKoLPNuKMiGve/6a6SFBpcPxMUPm/E/2EnmE/eP6qOaso74TcFTTlyrE8/
        bZzXj4FCQeUQi3SWyLGPWgYMqBaYIbs7o18k1Pr5P4cD1TFRuQi0/lE75ruvGNTlY2F8bxbJvNcDA
        bNlVu/UKw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUCYv-0006Vx-Dj; Tue, 04 Dec 2018 15:24:37 +0000
Date:   Tue, 4 Dec 2018 07:24:37 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 07/11] vfs: copy_file_range should update file timestamps
Message-ID: <20181204152437.GG32245@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-8-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-8-david@fromorbit.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 07:34:12PM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Timestamps are not updated right now, so programs looking for
> timestamp updates for file modifications (like rsync) will not
> detect that files have changed. We are also accessing the source
> data when doing a copy (but not when cloning) so we need to update
> atime on the source file as well.

This needs to be done inside the method, as a few file systems
do odd things about timestamps (yes, even now that XFS doesn't do that
anymore :)).
