Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FEB1C04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 08:12:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 19B482082F
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 08:12:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cQ79nVca"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19B482082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726198AbeLATX5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 14:23:57 -0500
Received: from mail-yb1-f195.google.com ([209.85.219.195]:44827 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726124AbeLATX5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 14:23:57 -0500
Received: by mail-yb1-f195.google.com with SMTP id p144-v6so3256227yba.11;
        Sat, 01 Dec 2018 00:11:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mHOADzJu3MQ2yY/Ub34TzHLgzchaGAnF+hUSOPs9cOk=;
        b=cQ79nVcaFbOlXO99E7kbnrJMURpm+UWOG6MfcHVIpSJVpc8PEPprPQmXyfbIgc7mDs
         AWAV4IeE7B+vLYj2H+errTgnYX8a8joZiAAUI7l7qEoqyf+G3FeQwLZbFPquuqbGO44c
         dL7iBCtdDTUKhMDSAJ96xkuj/9SG+4Uu66wQv7PwGgjpJtxiVpk6xoVfxIihvyRTwzTy
         kcZM6PYSTy5htrYMq8w7fn0iLHXwUADYR9L3T8AV5i1Xd7j+8622MDxzIAVQ8WPtmmN2
         XiRHMJ3SJhDMBbdA1IX5Zlr4jr9JcPvUpqmNQSlF1tk9YFje6FTRJvMBP85bF7QV3SBz
         V0jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mHOADzJu3MQ2yY/Ub34TzHLgzchaGAnF+hUSOPs9cOk=;
        b=TcfIKIG91+PMJe0Cthzf44Egz+PAox8v9HsMOBiJZYjtktJdiJcXtVe/VXeLYN5gS1
         EBEQq75zlHZXZpOCC5HqOc+I0nbP2R8NeH75smtAgBjBcm4bz3R9PabxrXGGqSwIFw1f
         mxXU1TX44gsNssu0fb6ho8aoJkEqifujbjccoHHdm3LVTxZigFFykW1WRfRslicEhiMW
         +W3B6X/JHV1uFS0fHQIC0MGCkAjwCbckAlNqy8rfI7qM/RM4Pur9XwaehYb2bOiQKrYl
         GLYEIrdKbXDULISMGjMTO6kZzlFeGzQU5Rjsu7cSpFAxlF7Qx+SqYTbdzPKYnNKAuM96
         1J1Q==
X-Gm-Message-State: AA+aEWaNG5TqTag63BuXm63Sv9rgTlAVl5PpTwBicRIkhUPdybi9tmla
        FM22elwj2BcAjGx3FwlpzHDVlqu9TP9II2tJFRk=
X-Google-Smtp-Source: AFSGD/U3KFwj8Fr/AH+/zEvucGCijYggXvJxRJECpCHHEYYOq6MikM8J3s3999LQFvqortiO+pSb/ERG8+SQytI5444=
X-Received: by 2002:a25:6004:: with SMTP id u4-v6mr8681312ybb.462.1543651919369;
 Sat, 01 Dec 2018 00:11:59 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com> <20181130200348.59524-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181130200348.59524-2-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Sat, 1 Dec 2018 10:11:48 +0200
Message-ID: <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Matthew Wilcox <willy@infradead.org>,
        Jeff Layton <jlayton@kernel.org>,
        Steve French <stfrench@microsoft.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> Relax the condition that input files must be from the same
> file systems.
>
> Add checks that input parameters adhere semantics.
>
> If no copy_file_range() support is found, then do generic
> checks for the unsupported page cache ranges, LFS, limits,
> and clear setuid/setgid if not running as root before calling
> do_splice_direct(). Update atime,ctime,mtime afterwards.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---

This patch is either going to bring you down or make you stronger ;-)

This is not how its done. Behavior change and refactoring mixed into
one patch is wrong for several reasons. And when you relax same sb
check you need to restrict it inside filesystems, like your previous patch
did.

You already had v7 patch reviewed-by 4 developers.
What made you go and change it (and posted as v2)?

Your intentions were good trying to fix the broken syscall, but
I hope you understood that Dave didn't mean that you *have* to
add the missing generic checks as part of your work. He just
pointed out how broken the current interface is in the context of
reviewing your patch.

In any case, I hear that Dave is neck deep in fixing copy_file_range()
so changes to this function should be collaborated with him. Or better
yet, wait until he posts his fixes and carry on from there.

If I were you, I would just go back to the reviewed v7 vfs patch.

Thanks,
Amir.
