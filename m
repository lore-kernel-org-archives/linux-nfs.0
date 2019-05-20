Return-Path: <SRS0=7+z+=TU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F018CC04AAC
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 20:51:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1F8421479
	for <linux-nfs@archiver.kernel.org>; Mon, 20 May 2019 20:51:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726011AbfETUvH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 May 2019 16:51:07 -0400
Received: from fieldses.org ([173.255.197.46]:57076 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726010AbfETUvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 May 2019 16:51:07 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id CE2933A2; Mon, 20 May 2019 16:51:06 -0400 (EDT)
Date:   Mon, 20 May 2019 16:51:06 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Xuewei Zhang <xueweiz@google.com>, jlayton@kernel.org,
        Grigor Avagyan <grigora@google.com>,
        Trevor Bourget <bourget@google.com>,
        Nauman Rafique <nauman@google.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: Show pid of lockd for remote locks
Message-ID: <20190520205106.GA29025@fieldses.org>
References: <CAPtwhKrJw54DmfVdP4ADd3w5QPv0cRP+kr1Atn58QOFL5xBGbA@mail.gmail.com>
 <3A924C3F-A161-4EE2-A74E-2EE1B6D2CA14@redhat.com>
 <CAPtwhKoF0XTuFa5msGB_eiiwRcJA0kK7eu6Rw6-b-5+8Qy0DDw@mail.gmail.com>
 <C5CB1B1E-59BD-4DB6-82D8-CE8E641CAC5A@redhat.com>
 <FF6B465E-DA4C-430D-ABEE-6053EF1E9A44@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FF6B465E-DA4C-430D-ABEE-6053EF1E9A44@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 20, 2019 at 10:22:00AM -0400, Benjamin Coddington wrote:
> Ok, I just noticed that we set fl_owner to the nlm_host in
> nlm4svc_retrieve_args, so things are not as dire as I thought.  What
> would be nice is a sane set of tests for NLM..

What would we have needed to catch this?  Sounds like it turns
multi-client testing wouldn't have been required?  (Not that that would
be a bad idea.)

--b.
