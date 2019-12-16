Return-Path: <SRS0=RpUm=2G=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E82A2C2D0BF
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Dec 2019 21:21:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C867122464
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Dec 2019 21:21:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726890AbfLPVVh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Dec 2019 16:21:37 -0500
Received: from mx2.suse.de ([195.135.220.15]:40018 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726646AbfLPVVh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Dec 2019 16:21:37 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id CD622B0B3;
        Mon, 16 Dec 2019 21:21:35 +0000 (UTC)
Date:   Mon, 16 Dec 2019 22:21:33 +0100
From:   Petr Vorel <pvorel@suse.cz>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/1] NFS: allow deprecation of NFS UDP protocol
Message-ID: <20191216212133.GA15392@dell5510>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20191126214336.9067-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191126214336.9067-1-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.12.2 (2019-09-21)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

Reviewed-by: Petr Vorel <pvorel@suse.cz>

Kind regards,
Petr
