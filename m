Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95119C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:03:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B3882147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:03:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729193AbfBSQDT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:03:19 -0500
Received: from fieldses.org ([173.255.197.46]:47092 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726244AbfBSQDT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 11:03:19 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 25FFE1CE7; Tue, 19 Feb 2019 11:03:19 -0500 (EST)
Date:   Tue, 19 Feb 2019 11:03:19 -0500
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>, dchinner@redhat.com
Subject: Re: [PATCH v2 00/10] server-side support for "inter" SSC copy
Message-ID: <20190219160319.GC19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com>
 <20181221190837.GB15842@parsley.fieldses.org>
 <CAN-5tyG6o2Zi61j=miGJpR-AmbzvAUm6x4wauzUC9JgQmpma+w@mail.gmail.com>
 <20190116220817.GA4499@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116220817.GA4499@parsley.fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 16, 2019 at 05:08:17PM -0500, J. Bruce Fields wrote:
> I have some delegation patches I want to get debugged first, hopefully
> just a couple more days.

Sorry for the delay, I should be back to the server-to-server copy
patches today and tomorrow.

> Where does the VFS cross-superblock copy work stand?  I remember Dave
> Chinner sending some patches but don't see them in 5.0-rc1, on a quick
> look.

(Adding Dave to the cc.)

I don't recall wha the remaining cross-device copy issues were.  Any
opinion whether they'd be worth a discussion at lsf/mm?

https://lkml.org/lkml/2019/1/18/696

--b.
