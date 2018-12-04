Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E47C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:19:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B12F420645
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:19:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RZ3e9aBv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B12F420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726152AbeLDPTc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 10:19:32 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:48028 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725910AbeLDPTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 10:19:31 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=wHoauxKBxjH0Ud4cfRovqndQQsea9E7tO/J7O8zs39g=; b=RZ3e9aBv8wyouSI0qbCE7UmJw
        SIC+zFEIEt9dDSaPd/TYyrB5ZrYUOs+BQO8rEQlaDADh+nq2h2rjT3ylc8Duh1KHs8AbuR4lbPI0h
        1rrJmWW4dEPqFFqJ+LPOxRadSd0RVomFDekKnZlD34OElX0UbdzkCoeFEeZR0PrVorm9TRNCKSKL5
        iyqmXM56RFrS2DVRvmmGZ22ME+HHTCID+dzdRFF9Cf56Fa4ir2AjYMyE5FdeZX5fQOovW+vAtxjER
        to8b7i/siFLw3LVm8zx3dAKI4sspBkQMrzbK7e2x5hfym8Rk4AT1pvRNKxxJ0a/1j4F9IiNcXZ9KT
        UApfesTBg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUCTz-000489-Fm; Tue, 04 Dec 2018 15:19:31 +0000
Date:   Tue, 4 Dec 2018 07:19:31 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 05/11] vfs: use inode_permission in copy_file_range()
Message-ID: <20181204151931.GE32245@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-6-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-6-david@fromorbit.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

As Darrick already pointed our this looks wrong - for "normal" file
operations, which copy defintively should be we should only allow
write access on a writable fd.
