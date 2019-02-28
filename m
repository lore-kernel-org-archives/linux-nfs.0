Return-Path: <SRS0=Ptm/=RD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1F01C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 22:26:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B0E420851
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 22:26:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="XyAqvOZO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726203AbfB1W0r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Feb 2019 17:26:47 -0500
Received: from mail-ua1-f50.google.com ([209.85.222.50]:36845 "EHLO
        mail-ua1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726189AbfB1W0r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2019 17:26:47 -0500
Received: by mail-ua1-f50.google.com with SMTP id e15so19425319uam.3
        for <linux-nfs@vger.kernel.org>; Thu, 28 Feb 2019 14:26:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fJ3rp+VqcQqEQe2s9J/UU+PGmOqM32dTA1nUxqYwPI4=;
        b=XyAqvOZOSqThRioDsGdZYt6AvwjftzpY/tn+NCPx4O0C6Nl5msKzsTUJYOObSUvj56
         oezk2pf2jenJ5Za0kZ+HKAY7ta/38DxD+efc5NiHaCBjJljlj4xgZms6NgGuyqZK52FF
         xmCEnpWKEUgXEEZ0Y8UyCQDUnQFia+4mlm7AGvxrAQ+uoJ7NFmGlwD3096FgzLK/rd+1
         sOZkJVmmZH8PwKnLkt4UTT8B9Gw5sowydbRzYADh2iz+d6TqssN1VBVhIoWbPSIc7A50
         mZIyijgEA1stYl8ih5pnKDHyEmhri0Cb0KeoUb0c3gH2YJv1L1IRVTAY1WKTmpmvAaUO
         YwZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=fJ3rp+VqcQqEQe2s9J/UU+PGmOqM32dTA1nUxqYwPI4=;
        b=VwJZA7NYxX34z+96OcnHszz1FH60by564MDbPbY0e3yXCxj4QYeAWa3jcSYcMzS8T4
         dTcXMM4PU0O0SlvGHYBO1DSVB+g/BZSHA+ugTTX6wP666CGY9F7X8ahnBdPmdS3f+xFK
         5Wo/Ay29JCvXL2P7Cjn2TujqMxelgCqxyMv6+A2Vu0HWOX5p2pIqYdzSMv1gbmeO905Z
         yNVW3ucmYpP9niU4QZNNI+iflajYK4jBrLV8t2/8qNQsRAQ57hHifgfSqompJyOxBHMH
         znq9NxRBi9v3WaSWCQsP2lFFXc+yFcATayLORklRAEEkymYoY4rjO6DdeAA4y08166dq
         Lv0A==
X-Gm-Message-State: APjAAAWdSitstXA5mJDX/VfYzgsaYoD3ofhIBgB9k2H3uf0Ggsjm1e1x
        bSfrHI9P/485ZFdasZfKUAT6qSztCFr+gvyZVJCQFw==
X-Google-Smtp-Source: APXvYqzsFLFmNolW+E74gjN4fcSNqxYl4OurTZkYDmX6v7dEpH3MvellaLaiLa9We+IJ1H0VdafL7JOgQWSaemFU/SE=
X-Received: by 2002:a05:6102:18f:: with SMTP id r15mr940120vsq.215.1551392805861;
 Thu, 28 Feb 2019 14:26:45 -0800 (PST)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
In-Reply-To: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Thu, 28 Feb 2019 17:26:34 -0500
Message-ID: <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Joseph Qi <joseph.qi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 28, 2019 at 5:11 AM Jiufei Xue <jiufei.xue@linux.alibaba.com> wrote:
>
> Hi,
>
> when I tested xfstests/generic/323 with NFSv4.1 and v4.2, the task
> changed to zombie occasionally while a thread is hanging with the
> following stack:
>
> [<0>] rpc_wait_bit_killable+0x1e/0xa0 [sunrpc]
> [<0>] nfs4_do_close+0x21b/0x2c0 [nfsv4]
> [<0>] __put_nfs_open_context+0xa2/0x110 [nfs]
> [<0>] nfs_file_release+0x35/0x50 [nfs]
> [<0>] __fput+0xa2/0x1c0
> [<0>] task_work_run+0x82/0xa0
> [<0>] do_exit+0x2ac/0xc20
> [<0>] do_group_exit+0x39/0xa0
> [<0>] get_signal+0x1ce/0x5d0
> [<0>] do_signal+0x36/0x620
> [<0>] exit_to_usermode_loop+0x5e/0xc2
> [<0>] do_syscall_64+0x16c/0x190
> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [<0>] 0xffffffffffffffff
>
> Since commit 12f275cdd163(NFSv4: Retry CLOSE and DELEGRETURN on
> NFS4ERR_OLD_STATEID), the client will retry to close the file when
> stateid generation number in client is lower than server.
>
> The original intention of this commit is retrying the operation while
> racing with an OPEN. However, in this case the stateid generation remains
> mismatch forever.
>
> Any suggestions?

Can you include a network trace of the failure? Is it possible that
the server has crashed on reply to the close and that's why the task
is hung? What server are you testing against?

I have seen trace where close would get ERR_OLD_STATEID and would
still retry with the same open state until it got a reply to the OPEN
which changed the state and when the client received reply to that,
it'll retry the CLOSE with the updated stateid.
