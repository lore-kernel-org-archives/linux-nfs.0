Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2DA7C5519F
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Nov 2020 17:01:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3ADE62068E
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Nov 2020 17:01:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OT1gUVI3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725973AbgKLRBr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 12 Nov 2020 12:01:47 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:38378 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725903AbgKLRBr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2020 12:01:47 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1605200506;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type;
        bh=+k3D5bacduzGFcoMR9y7oBsPfhBoQH/3lfgQLGdxA/4=;
        b=OT1gUVI3q1msNVQkXJUZ/ZZ92Ftt7WKt5juu0OboZCS9cZ4PGEO0K0KW1639dgRPV24Gv0
        RESxjZFOBCdyrTlpuz7PGUoG9vB/F21CjmEiZBFFuWhUI0MvaeUCUvJ3oyHzwrxvfymCli
        BPRD9r5qztPFAjZL3dtwWTdQuHtbe8M=
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com
 [209.85.208.72]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-375-E2xIzsonNmezkblLBaUDPQ-1; Thu, 12 Nov 2020 12:01:42 -0500
X-MC-Unique: E2xIzsonNmezkblLBaUDPQ-1
Received: by mail-ed1-f72.google.com with SMTP id n25so2577665edr.20
        for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2020 09:01:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=+k3D5bacduzGFcoMR9y7oBsPfhBoQH/3lfgQLGdxA/4=;
        b=Y+/9DRKYYln1h1+8/KCI37mPbPMesg5XSqr3VrEMdiGVO03e08gFiUKwtoxgplchDq
         aoIVtX/j0eHL05h5oIYdWdrvtX/k/6bKXY65pHjUw2YBbw0k5aIaah636IORj1gByJOA
         XHR0vV8oDuYFtZb4IubI9TYoETM+weLt+t9XxsgxvNcxWUrlwqt2Rabe87ZpCR0h6wWY
         WSFuVcmMG3e6lcx8aV0GbTpeJVfssqzAjHUTCh558bUNiSqwfXQxZh9VpXc3QaC0oSg/
         TRdFqUxfF4IJzGmAThGg50kGoilnDg1qJgqpM/JfDsN86dZGNGQWpf0wrLuqv4SxihWL
         BRog==
X-Gm-Message-State: AOAM532ftChJBVMWfnIpMKCte0HrvyeuGe1BIkdK05Gn5dRwERtIkFnc
        mzuasskmT2SzCUR1uspY0wjcqaugRmCdFbvySS1i7pq6Ie8bxyBwpC63GrYQmNh11CJ42zAa5C9
        avlXfnC4xiGqovymEsE7QRIl8T7MPbdoMmlGl
X-Received: by 2002:a17:906:ccc5:: with SMTP id ot5mr242253ejb.248.1605200500389;
        Thu, 12 Nov 2020 09:01:40 -0800 (PST)
X-Google-Smtp-Source: ABdhPJzutkYhJy9I1S82gzpcNi8SdF5rRkrpbbcIz1xFb03G8JBN5Hy31ZDsDk1RPmxC4cRQJqc63vyYg3l6KJ9ONGA=
X-Received: by 2002:a17:906:ccc5:: with SMTP id ot5mr242213ejb.248.1605200499795;
 Thu, 12 Nov 2020 09:01:39 -0800 (PST)
MIME-Version: 1.0
From:   Vadim Rutkovsky <vrutkovs@redhat.com>
Date:   Thu, 12 Nov 2020 18:01:28 +0100
Message-ID: <CAKO8Qe496svrBnO27O8ugXOSVMGwaqe4Nv4K2ecT6pZG_WC07A@mail.gmail.com>
Subject: Bug 209399 - Can't unmount bind-mounted NFS mounts with "Stale file handle"
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hey,

Fresh kernels (starting 5.7 up to 5.9.8 in Fedora's update-testing)
are hitting an odd issue -

"Stale file handle" error is thrown on NFS share when bind-mounted dir
is removed. See reproduce steps in
https://bugzilla.kernel.org/show_bug.cgi?id=209399.

This is unexpected, affects all kernels since 5.7.7 and breaks
kubernetes conformance tests.
Could someone have a look and see if there's a workaround or a fix?

-- 
Thanks in advance,
    Vadim

