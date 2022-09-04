Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B7BC54EE9
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Sep 2022 08:50:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229815AbiIDIuO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Sep 2022 04:50:14 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55568 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229537AbiIDIuM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Sep 2022 04:50:12 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7D625303E1
        for <linux-nfs@vger.kernel.org>; Sun,  4 Sep 2022 01:50:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1662281410;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=4IccMBIxX+PSaiDwmAN+nA6tZvbJnmKwnOFFRWTaiQ4=;
        b=AoyCvLNZFNDT7zOnaBVvY24lyTHa4L3MCtYgUTqQstGZ7KNIml4dZPdca2wyTMZ8W61ik7
        UcpPNXlsIFmnW5rKfzw1pS06Qrfu/GSYgKI2jLTIOsk32T8qrwvipH+ONGSU27eoRtjR5u
        NS9JcEyOA1rmFIUHnYiB80Vu9T3H0zg=
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com
 [209.85.208.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_128_GCM_SHA256) id
 us-mta-50-93gTHfF4MPyYu-4MJyO6ag-1; Sun, 04 Sep 2022 04:49:59 -0400
X-MC-Unique: 93gTHfF4MPyYu-4MJyO6ag-1
Received: by mail-ed1-f70.google.com with SMTP id w19-20020a05640234d300b004482dd03feeso4062521edc.0
        for <linux-nfs@vger.kernel.org>; Sun, 04 Sep 2022 01:49:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date;
        bh=4IccMBIxX+PSaiDwmAN+nA6tZvbJnmKwnOFFRWTaiQ4=;
        b=FZBV0X7I55cujoskh5oGzyDxQhSeBgMb9hriZLw5iE3q2tK5nEN++aN+1ecr3d5XdV
         V8lr2ljGdukI0RAMXbx+YqWOpAVkTpHu6Ktb05KGsi8oFP9pgJ4oYZ2cIM1xDjgUbgQL
         3u1NokdUJbW0Twh0+WUiN9wXuEwAfPKQFgv1aP0RF6zFPGUjDoFmLr0WjiqqxyWL4kqs
         0Vc3WW5Lc1oy+UuvL69rW1VpUXBRQTzU5LHoCMWByaSEQPlH86/iS/Y+5q87qalVFeLB
         ZOiSquD/d8s39S2/uuYPB6lpkat0dxnZLkR2kLeV5s1b5NfCk2jWWvvMdRscUxECpaWq
         5Q3g==
X-Gm-Message-State: ACgBeo2V5Ts75Ma64JCrU9RT8Xt4IdvTNzBtHziyIMPWAhoOGL8Po5mT
        sDYulDYClaxGjjCYa6L9kctgFB1TeY7cNlIc3p7NqCEBqR/nKHFSl8xrVH9skCW4nLI+Btrlkp5
        gQr5f/eHPGWabZI5TJtAUAIzIKCm1FHM8IoRe
X-Received: by 2002:a17:906:7714:b0:74f:f771:4e0 with SMTP id q20-20020a170906771400b0074ff77104e0mr7247123ejm.623.1662281398532;
        Sun, 04 Sep 2022 01:49:58 -0700 (PDT)
X-Google-Smtp-Source: AA6agR7GWmOQP5L6NgokG8GdLGx7Oj5xKtNWYtmiCninLP5NIKFthrhidP5D3ztGKoQshmmVZsdJIr6/fqY4j6K2mmc=
X-Received: by 2002:a17:906:7714:b0:74f:f771:4e0 with SMTP id
 q20-20020a170906771400b0074ff77104e0mr7247114ejm.623.1662281398321; Sun, 04
 Sep 2022 01:49:58 -0700 (PDT)
MIME-Version: 1.0
References: <3E21DFEA-8DF7-484B-8122-D578BFF7F9E0@oracle.com>
In-Reply-To: <3E21DFEA-8DF7-484B-8122-D578BFF7F9E0@oracle.com>
From:   David Wysochanski <dwysocha@redhat.com>
Date:   Sun, 4 Sep 2022 04:49:22 -0400
Message-ID: <CALF+zOnrKU-ba3aRcdvJvEuZv2kP_Pg7CpotuSkkEofipEZ0-w@mail.gmail.com>
Subject: Re: generic/650 makes v6.0-rc client unusable
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "fstests@vger.kernel.org" <fstests@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Sep 3, 2022 at 2:44 PM Chuck Lever III <chuck.lever@oracle.com> wrote:
>
> While investigating some of the other issues that have been
> reported lately, I've found that my v6.0-rc3 NFS/TCP client
> goes off the rails often (but not always) during generic/650.
>
> This is the test that runs a workload while offlining and
> onlining CPUs. My test client has 12 physical cores.
>
> The test appears to start normally, but then after a bit
> the NFS server workload drops to zero and the NFS mount
> disappears. I can't run programs (sudo, for example) on
> the client. Can't log in, even on the console. The console
> has a constant stream of "can't rotate log: Input/Output
> error" type messages.
>
I've seen this occasionally as well.

> I haven't looked further into this yet. Actually I'm not
> quite sure where to start looking.
>
> I recently switched this client from a local /home to an
> NFS-mounted one, and that's where the xfstests are built
> and run from, fwiw.
>
My testbeds have xfstests built/run on a local filesystem.

