Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB25C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 08:26:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3539A207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 08:26:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="M95ZIt2U"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729457AbfDBI0K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 04:26:10 -0400
Received: from mail.skyhub.de ([5.9.137.197]:44638 "EHLO mail.skyhub.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729162AbfDBI0J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 04:26:09 -0400
Received: from zn.tnic (p200300EC2F148A00329C23FFFEA6A903.dip0.t-ipconnect.de [IPv6:2003:ec:2f14:8a00:329c:23ff:fea6:a903])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 16FE01EC0229;
        Tue,  2 Apr 2019 10:26:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
        t=1554193568;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
        bh=fFyk35a0i9B/qqjl+zGbS7VnRfRcgLbnaPrieg/l+QQ=;
        b=M95ZIt2Uunugu90TiG9geiID/PHq7uTk4Hf8ImpZHyZUEYfozz1AhorggMIAPsZ68+9E0n
        5BW+BMAj5VIFG2D2c8wZCFpqz3oH6Rde3qifDVa2umXYjd6hHBl9jNyRsW7KVoWRSDVhu3
        krNt+74QHzMzBciYZTLWx4iN+9b80P0=
Date:   Tue, 2 Apr 2019 10:26:02 +0200
From:   Borislav Petkov <bp@alien8.de>
To:     syzbot <syzbot+51c9bdfa559769d2f897@syzkaller.appspotmail.com>
Cc:     anna.schumaker@netapp.com, bfields@fieldses.org,
        davem@davemloft.net, douly.fnst@cn.fujitsu.com, hpa@zytor.com,
        jlayton@kernel.org, konrad.wilk@oracle.com, len.brown@intel.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        mingo@redhat.com, netdev@vger.kernel.org, puwen@hygon.cn,
        rafael.j.wysocki@intel.com, syzkaller-bugs@googlegroups.com,
        tglx@linutronix.de, trond.myklebust@hammerspace.com,
        trond.myklebust@primarydata.com, vbabka@suse.cz, x86@kernel.org
Subject: Re: WARNING: ODEBUG bug in __do_softirq
Message-ID: <20190402082602.GA6826@zn.tnic>
References: <001a1143e62eb6a9510565640e76@google.com>
 <000000000000bd253c058585101e@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <000000000000bd253c058585101e@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 01, 2019 at 10:04:01PM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit 5b317cbf2bcb85a1e96ce87717cb991ecab1dd4d
> Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Date:   Fri Feb 22 09:17:11 2019 +0000
> 
>     Merge branch 'pm-cpufreq-fixes'

That looks like the bisection is at least imprecise, if not gone into
the weeds.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
