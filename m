Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E847C282D7
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 11:59:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C4F4217D6
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 11:59:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KuI63LZx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728271AbfBEL7v (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 06:59:51 -0500
Received: from mail-wm1-f66.google.com ([209.85.128.66]:39582 "EHLO
        mail-wm1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728083AbfBEL7v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2019 06:59:51 -0500
Received: by mail-wm1-f66.google.com with SMTP id y8so3326563wmi.4;
        Tue, 05 Feb 2019 03:59:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=c3iDW75+ytF85PwEa+aYxuVs8pxojtxW6P/2+Hqedg0=;
        b=KuI63LZxax1nrincQHDPVBH4TR/1FE5+/IE6OVjXbG3tmaZDbvHmHyJi0Lm7LwRLmA
         B6ErBXIjl35RzEAutph+dNY9zxFEQYrEbq2jdFN3C/ZMIlf9ZClboDE+gamw7Hve3ktG
         UuFa7z/U305U1WqCOMlxu64kYQsC8EIk/AthEVvVbSwJ3UwOWqSO7KylwDvTtYt9hx/I
         7xwjfOrPwdJNtlm5lNqwLYLkE4uxFVuCq3GuKda/3t2rSiRxnbZvLOWo0kMKVp5MieQs
         BLKkIvCmU+dgzhdUCIXYUZAnEZxeH92FSYlnW9aufJMBGMOnS6ubFN6+tsLI/WDjYkGC
         qaig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=c3iDW75+ytF85PwEa+aYxuVs8pxojtxW6P/2+Hqedg0=;
        b=abMkL40HdmMgj6SEYt7s0Dp01ytSoSXvJmiCj4IjaJFbclStvojxNOgweYpCxo64AU
         8MLY3plXV/T9azljVvAMSD63oQjMzaQh48hH0Mg/WkMunOAyd6Offog2k/Yvao2/OQfl
         7en08NKJLmFA8f8j/56dqJ7aoLTj6Nes0BqcJqPg9x6C0vp1uj4lz2LvT2i8RGJVmfKl
         6G2toMzYTuZ+wU9sA7dR79y5RPYaGOqvvmBbGSBqGj/GLAWnl4O7g25rKLWr9FfflDTf
         kb3q9G4YYsgTX083Hlt+kJWs7CMgLes6ee2O8VYyX9CWnzPF/TK3ygJNoDeIWbQkQjot
         Enjw==
X-Gm-Message-State: AHQUAuYoEghCMk2lmntGo9xzpwtNn4sb5nt3wXj2gOYiIvM5UJc+lcF7
        xDTR/qE3jC1ymVrDxI/yjJ9oCEYMQps=
X-Google-Smtp-Source: AHgI3IZ7ndxiB0JO7DPYE1ZVIwY6D3bpaJEvA5vM4Km23WiPXRh6SGiHoll9G+3g8TCQQtDFII6xkw==
X-Received: by 2002:a7b:c951:: with SMTP id i17mr3721053wml.70.1549367989695;
        Tue, 05 Feb 2019 03:59:49 -0800 (PST)
Received: from lorien (lorien.valinor.li. [2a01:4f8:192:61d5::2])
        by smtp.gmail.com with ESMTPSA id w10sm33163803wmb.1.2019.02.05.03.59.48
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 03:59:48 -0800 (PST)
Date:   Tue, 5 Feb 2019 12:59:48 +0100
From:   Salvatore Bonaccorso <carnil@debian.org>
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205100141.25304-1-buczek@molgen.mpg.de>
User-Agent: NeoMutt/20170113 (1.7.2)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Donald,

On Tue, Feb 05, 2019 at 11:01:39AM +0100, Donald Buczek wrote:
> Please include the upstream patches
> 
>     *  commit 085def3ade52 ("nfsd4: fix cached replies to solo SEQUENCE
> compounds")
>     *  commit 53da6a53e1d4 ("nfsd4: catch some false session retries")
> 
> into longterm kernel 4.14.
> 
> Because these patches went upstream in 4.15, they are already
> included in longterm 4.19 and stable.
> 
> A nfsd4 server failure, where the server sends unrelated replies
> to client requests containing only SEQUENCE operations has been
> experienced with kernel version 4.14.87 [1]. Because the client
> retries endlessly, this completely breaks the nfs mount.
> 
> A backport of these patches has been suggested by the patch
> author J. Bruce Fields. [1]
> 
> Only limited testing has been done (running a single server with
> 4.14.96 and these two patches for a week and generating some high
> load on it). It can not be proven by testing, that the patches
> really fix the experienced problem. However, as the patches are
> part of upstream and stable kernels for over a year
> they should be a save pick.
> 
> Backport note: Only line numbers updated.
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=202435
> 
> J. Bruce Fields (2):
>   nfsd4: fix cached replies to solo SEQUENCE compounds
>   nfsd4: catch some false session retries

Are you planning to submit the same as well for 4.9 LTS? The two
commits apply on top of 4.9.154 with line number updated.

Regards,
Salvatore
