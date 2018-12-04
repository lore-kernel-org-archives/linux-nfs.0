Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EDE1C04EBF
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:21:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0577B2081C
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:21:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UW6FCzFn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0577B2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726662AbeLDPVw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 10:21:52 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:50214 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726151AbeLDPVw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 10:21:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=PLzMEtoxgTTufh7AvF2024zErofYxIF+4vFXJAiMvkk=; b=UW6FCzFnR6ad555YD9NakU/Z8
        tOoGrV5TK0ob8rdWss8WGMj2HYkjeNRsXTRLcFg+EYj+KGfA5vH/d+61LdTC0WS6lZhGWdH5VmwMU
        DDexxZFPTEjy7LN4/RQZMUbGsFK6Lj3Uv9XK4KMWni3hlNSsVsXi6K5fQ7eZO1MK/7kXALzF2SJYu
        z8lLhJjzd2SztyTIwaGdqtssEvCoX92LVoxR8vsFqYrzdRyaLgeRDMJ4VL1W16TJWYz1C1AoUNru3
        sMIvfSoYIzxuao95cKQa3hUFWnxZYbJsfqcoxiquGT94ZfiLO79gL/FgoVL390DXUtGIyNOch++SR
        QeawVg6VQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUCWF-0005q1-UU; Tue, 04 Dec 2018 15:21:51 +0000
Date:   Tue, 4 Dec 2018 07:21:51 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 06/11] vfs: copy_file_range needs to strip setuid bits
Message-ID: <20181204152151.GF32245@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-7-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-7-david@fromorbit.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

file_remove_privs needs to be called with i_rsem held, which I don't
think we do here.  It also really should be called under the same
i_rwsem critical section that does modify the file content, so we'll
have to move the call into the methods.
