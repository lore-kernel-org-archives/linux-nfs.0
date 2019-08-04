Return-Path: <SRS0=YLGR=WA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBD56C433FF
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Aug 2019 21:10:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9B7D52086D
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Aug 2019 21:10:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=delphix.com header.i=@delphix.com header.b="Oe0WxvrS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726738AbfHDVKK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Aug 2019 17:10:10 -0400
Received: from mail-io1-f48.google.com ([209.85.166.48]:41011 "EHLO
        mail-io1-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726524AbfHDVKK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Aug 2019 17:10:10 -0400
Received: by mail-io1-f48.google.com with SMTP id j5so159131083ioj.8
        for <linux-nfs@vger.kernel.org>; Sun, 04 Aug 2019 14:10:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=delphix.com; s=google;
        h=mime-version:from:date:message-id:subject:to;
        bh=SCk6PbQLyCvNtjlM9F64fu9HxoHFl9Tt6JwULzQSCr8=;
        b=Oe0WxvrSTEUOSv3wU/cEyBRSri2A8e3K9UUgNMiVkCA0T3/Oqxk90WJkB51fWt5GNU
         WXPe97fumQht/B6neFZgCIXUq2WbiOaTE8bpcwyFKK6lXsqxLqDHZGpAUWKLgzzwAS85
         Jgwxjds6MLjpfIFYbwFFgGdCDqvGh5ZIM8zoI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=SCk6PbQLyCvNtjlM9F64fu9HxoHFl9Tt6JwULzQSCr8=;
        b=L4K8JzPrNz8LUJH0bpmew5y3tp5W+S5xuo/lkPeH0SE4SrkKMkL/T1mwUlGo3e9+cN
         ul7zZCQcrqz+FXhjmzD6zzwgc8M0UtP0Ev602HYbrS4xVWMTZI2ui7fauqoA9Nss73i2
         Teb40P+jHHAVOEc1aAPGpwvBgVFhKODaUTKCHvJUn7ZHcoE4lPaX1t32SCqznZXczq9o
         oepsRJppMjYrtu4FQ+NM8GXxThGENuIqyEhAyk5ygHXVlbQOgoGr7CaOO8nMhWEHrAK2
         xGfhYnAmHlIEeFnZD7YzZafDjODZU0J6WGYECX9/ZKAj09tGDFLwC30EsT6RHxOLlOw7
         nTgA==
X-Gm-Message-State: APjAAAU5cioCR4pq8WbzUF4rqi2gu7XmxPTcXsfyws4dh3WjrbmUoLwv
        TNtWTniLJf0cRy9IqN2sEq+cppzVNB8Mfv1lXGPk66JhhQw=
X-Google-Smtp-Source: APXvYqwTzlF6QdPgnupshHwClsNjDpibW6jhnCdsv6ESdvx+P+Mm8IzJw/LxLk/fKm4rsqOtY0gkaNhj10yNgXln8Co=
X-Received: by 2002:a05:6638:201:: with SMTP id e1mr69004349jaq.45.1564953009389;
 Sun, 04 Aug 2019 14:10:09 -0700 (PDT)
MIME-Version: 1.0
From:   John Gallagher <john.gallagher@delphix.com>
Date:   Sun, 4 Aug 2019 14:09:33 -0700
Message-ID: <CANHi-RdNP6X1cyqN9z4SfHeC+NmAU+j9a1B03=rASF7_bDDGLQ@mail.gmail.com>
Subject: Clients mounting subdirectories with NFSv3 can prevent unmounts on server
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a client mounts a subdirectory of an export using NFSv3, the server can end
up with invalid (CACHE_VALID bit unset) entries in its export cache. These
entries indirectly have a reference to the struct mount* containing the export,
preventing the filesystem containing the export from being unmounted, even
after the export has been unexported:

    /tmp# mount --bind foo bar
    /tmp# exportfs -o fsid=7 '*:/tmp/bar'
    /tmp# mount -t nfs -o vers=3 localhost:/tmp/bar/a /mnt/a
    /tmp# umount /mnt/a
    /tmp# exportfs -u '*:/tmp/bar'
    /tmp# umount /tmp/bar
    umount: /tmp/bar: target is busy.
    /tmp# cat /proc/net/rpc/nfsd.export/content
    #path domain(flags)
    # /tmp/bar/a    *()

It looks like what's happening is that when rpc.mountd does a downcall to get a
filehandle corresponding to a particular path, exp_parent() traverses the
elements in the given path looking for one which is in the export cache. If
there isn't a valid entry in the cache for the given path, which there won't be
for a subdirectory of an export, then sunrpc_cache_lookup_rcu() inserts an
new, invalid entry.

Are the invalid entries inserted while executing exp_parent() useful? Could we
prevent them from being added?

Thanks,
John
