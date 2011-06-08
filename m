Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59738 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab1FHRdg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 13:33:36 -0400
Received: by yxh35 with SMTP id 35so297023yxh.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2011 10:33:36 -0700 (PDT)
In-Reply-To: <3FA034197108F04082D2AE1401CE0F3832AB05C6@VICMAILBOX.pronto.com.au>
References: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
	<BANLkTi=4ey0YpTtUwuVuRQz4_xYpt10wuw@mail.gmail.com>
	<20110607232313.GG13911@fieldses.org>
	<3FA034197108F04082D2AE1401CE0F3832AB05C6@VICMAILBOX.pronto.com.au>
Date: Wed, 8 Jun 2011 10:33:35 -0700
Message-ID: <BANLkTim=4jFHoucL4jXf5aPun3AxEThM+A@mail.gmail.com>
Subject: Re: NFS Sync with External Journal
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tristan Ball <tristanb@pronto.com.au>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 7, 2011 at 8:57 PM, Tristan Ball <tristanb@pronto.com.au> wrote:

... [snip]

> Doing the exact same test on a filesystem backed onto some SSD's  gets me up to about 100-105MB sec, although the write latency on these is much lower than the 5400 disks.
>
> I'll get back to you on the ext3 mailing list responses, I'm going to redo my tests on ext4 first.

I'm also interested in the subject. More specifically, if users are
handed a bunch of SSDs and/or NVMs, what can they do to leverage the
hardware features for functionality or performance improvement ?

Do keep us informed.

-- Wendy
