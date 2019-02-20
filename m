Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EF79C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 11:29:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D485920851
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 11:29:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YMnzX8Do"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726773AbfBTL3H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 06:29:07 -0500
Received: from mail-lj1-f175.google.com ([209.85.208.175]:37006 "EHLO
        mail-lj1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726686AbfBTL3G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 06:29:06 -0500
Received: by mail-lj1-f175.google.com with SMTP id a17so4155281ljd.4
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 03:29:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=tF5th9JQz1BpjNbasVtk9Lb8KvCqKdBdGiKRxkaYF0g=;
        b=YMnzX8Do8XEeJ6PvCtW9UTzpF6qNBlNtgr2wrFzZ1MvHHgScsYjznON1JG9onKIe6N
         KbStUWpwgXdcVxNX7qabUfNl95EkK8NPd+Q0u/bB/yDcUXJnaq+I0HsHnvxaYwjk62Uu
         LOEZXx0weOVGSA1/GuCv4qBUPfXHAC3sKvMaGvbXhyCzf4fQBBGm27F0Bl28AAZqts+I
         iXFK1tKuVVMLRMUbpOuVEv+NhAhFqIfY2GcisDb0jqHXboBFVqIcT1lrWPripTpFNn4L
         7agZtthtzzidmWbUkO1LXUJC1s7v9+yly8OJsZ9aeo0l95CbHzPG0IcyYgH/H40D9QpC
         OKeQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=tF5th9JQz1BpjNbasVtk9Lb8KvCqKdBdGiKRxkaYF0g=;
        b=Gm5iLzgU3mhrjPASy5VGjGz6lCDXNEF/E3RZJTMcf974hoxpfkwbt9eDCsUNrXLOGj
         P8D48CLULXolIMSMLNaoo6FccdeBiY9KvZfE4GPQKRaLT0Z9BzLcdNMe/o5dG6OGNn97
         H+63TPDE4/dr8OlqVB6gIbfT6bXzyQSAIcizyRAIFfX7geU2/Eve0r9gSlpuPprCacPF
         83hcVdJbtcc8vR2XoPZ4Kbf3OCL7/HWWIDMXsuXgDo2lZrypMIU95qrg7ur3TAVwgxZA
         yvEKjNXqzSXUAp2zve8LTjbndSWydDJkTEiXPRYSJ+Wng2O79UoaWDdT3gSe1Y6+Ztpy
         xoow==
X-Gm-Message-State: AHQUAuZTXHUzJ2TI5kfb2+9R6PIT/gIEE4iug2/DGEk6PHF7Hg1HkjC/
        7gVfi5KC/3b1yVtG50mVMc608tNd2xckTvtJnAeTJV+w
X-Google-Smtp-Source: AHgI3IZRijHqVTcHA1ne038kzGCnqEmk6tnfa6l5wxX7yy9MmvPKvuP+AYVCkgJ9PrXmsH75GUijngGxLz+iViMl28M=
X-Received: by 2002:a2e:8496:: with SMTP id b22mr1777908ljh.143.1550662144340;
 Wed, 20 Feb 2019 03:29:04 -0800 (PST)
MIME-Version: 1.0
From:   James Pearson <jcpearson@gmail.com>
Date:   Wed, 20 Feb 2019 11:28:53 +0000
Message-ID: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
Subject: nfsd thread limit and UDP ?
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On a very busy NFSv3 server (running CentOS 6), we recently upped the
nfsd thread count to 1024 - but this caused client mount requests over
UDP to fail.

We configure all our clients to use TCP for NFS mounts, but the
automounter (automountd) on MacOS (up to version MacOS 10.12) seeds a
'null call' to the NFS server over UDP before attempting the mount -
but the server appears to ignore any UDP requests - and the automount
fails

I can also reproduce the issue on a Linux client via:

 mount -o udp,nfsvers=3 server:/export /mount/point

I've found, by trial and error, that the maximum number of nfsd
threads that can be run on the server is 1017 before UDP mount
requests fail

Running tcpdump on the server shows the UDP requests from the client,
but the server never replies

It looks like more recent versions of MacOS will do its test 'null
call' over TCP - so that is one 'solution' to this issue

However, I'm interested to know if we're hitting some hard limit, or
if there are any settings we can tweak that could mitigate the
problem?

Thanks

James Pearson
