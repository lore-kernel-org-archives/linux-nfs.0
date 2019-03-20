Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D870C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 15:47:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52F992146E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 15:47:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=qumulo.com header.i=@qumulo.com header.b="M4rayo2h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726595AbfCTPro (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 11:47:44 -0400
Received: from mail-qk1-f175.google.com ([209.85.222.175]:44185 "EHLO
        mail-qk1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726529AbfCTPro (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 11:47:44 -0400
Received: by mail-qk1-f175.google.com with SMTP id m65so6795604qkl.11
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 08:47:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=qumulo.com; s=google;
        h=mime-version:from:date:message-id:subject:to;
        bh=5+P3KGX1k259XFgNl6YSMrMy9hu3hIrEldmvQQHuMag=;
        b=M4rayo2hNC7kykc7inX02sLmrTOompHT59BzqJkMaVuMWGMfNzPctDZezS9Ep/EiWt
         WDUpgVYGomRYnaEFxzjnVnEnwt2XINhFoZuZVTW+IWsx1a1v78gT1+/k16oOsZHKXYUF
         fcDmXWeavIrWqE/HbTDN45s8oqxVPkR9FHPk8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=5+P3KGX1k259XFgNl6YSMrMy9hu3hIrEldmvQQHuMag=;
        b=pBRUBCQnmsNyyW2IyHA1jBIaCtfQHP2cozmqNYqDkMOToJ86wKziVCS9tg1sr3O/cH
         VZjz6GzNZmhcNV61yLJwwQGHWpRJc3CRvqUCWGCTIR1gvt5xnxTKZvu4/NJsrVqnvxJf
         kVp28eU1Nna/VbU1+6vGyUmJwp4L44Bb9JnrvPDmYHMxdDf2nJD5+JUPL3dwNKOmoUMc
         /xFmWNqKkP8ZD0bnqIT4thpSsAzRndDUBH8nGd6gYfTPBDeZ05EUf84qOJZWlLvj83zb
         pALIdoamlQivd3JlzAMJK7i18TI8YCdID1bQTIApTuE9vqhbusg2/TaHA/5CGPmi7FeA
         ZAoQ==
X-Gm-Message-State: APjAAAWo1cxqfafdoeogEJwg7icbWCfJzRzAYElFNN76OPW8NsqLZIfw
        mfWhTRebTAKHs0TZNRD/Hx7Rds+hk4LVYzGRGwlhwoQzCMM=
X-Google-Smtp-Source: APXvYqwQZnP6Yn3lbgKaPjS12DQ/njl24xq9OI6zSCDTGhll1uxFmOM8N2yy4lEjBJbknrOvT9r74sVt8Hm6dl1wPmg=
X-Received: by 2002:a05:620a:30a:: with SMTP id s10mr6914198qkm.54.1553096862948;
 Wed, 20 Mar 2019 08:47:42 -0700 (PDT)
MIME-Version: 1.0
From:   Ted Carpenter <ted@qumulo.com>
Date:   Wed, 20 Mar 2019 08:47:32 -0700
Message-ID: <CABu8kFdbzgEnoWh595+ODPt4cTaWryO9OR9fKVB68z+tfbNaCA@mail.gmail.com>
Subject: Collapsing I/O size with unstable writes with NFSv3 on 4.15
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'm testing performance of a clustered NFS server using a 4.15 client.
My test setup involves running IOZone to write a 30GB file to the
server over NFSv3. The issue is that we occasionally see bad
performance, especially when unstable writes are enabled on the
server.

Based on observing the network traffic, we've seen the write I/O size
during good runs stay around 1MB (which is how we've mounted) but in
the bad runs we see often see dips in write size (down to even 4KB or
8KB) towards the end of the test.

I'm trying to understand why we see the dip in I/O size from the NFS
client as it seems to be related to the decrease in performance. Any
ideas what could cause it? Also, any suggestions on where I should
look to start learning about the way the Linux NFS client and page
cache handle unstable writes internally?

Thanks,
Ted Carpenter
