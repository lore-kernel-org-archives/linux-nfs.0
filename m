Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FROM,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8518C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 16:01:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 779802186A
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 16:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V36fZcfn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730602AbeLUQBD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 11:01:03 -0500
Received: from mail-it1-f179.google.com ([209.85.166.179]:36040 "EHLO
        mail-it1-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730365AbeLUQBD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2018 11:01:03 -0500
Received: by mail-it1-f179.google.com with SMTP id c9so7208819itj.1;
        Fri, 21 Dec 2018 08:01:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EA3gf/Ddcghu2A3oSFbzw96Oows3ZOvFFqVI4E1akhc=;
        b=V36fZcfng2A+tI+3OtBAhcS+8NYF/LFYQbrOq4mf/o/n3ciJeQ2V4ioqD44185YPEM
         6KLtSfM+9xzGGymDT+3NQ/quuIYJ4nfdUBGClDe/sTHrpbCY93tGGx536ElOlYH1GJ99
         9+wa2sSRr/7FcQt8fDjks5kZR6uST+CMtNkAO4xmdaLy3sSpzalFTjgiJSECH7fq+iKt
         tngAbwSKcZ1wtISWjZNvpWh0b73ojGIAP/4PWJdXaBtFAqRkJ6tlJMqTV22QB3Rl4mQk
         LJIYHGEiS6Udc6nT4SK+99lAINWN6VnYPP0VUoQT9nU7WjWDiJM2a35GuJiv3TZiny10
         q7DQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=EA3gf/Ddcghu2A3oSFbzw96Oows3ZOvFFqVI4E1akhc=;
        b=RZsZoaOAoLu4iEojUn6xnb6i5tyKqKO/ezgbvmjjGTw+fLdhjWNnU4w+klIyjNPa/g
         W71na205+m+FVHOnx3pGFzhYqsyyZNIlRRHflySQc2VKpJw8QCPH6iqauz6IwYANEcIC
         ECxbPTc3/0P9Cld2cOzKBM2+Q8E7SD/fPlmDg5TeYF7zWSU3Q74meFRLG4pGt1/+sGhM
         5azGnaN0uZTNMsG64gDzrYVZORrhvYlZko6stIuE4Fs6do8bwOtExDtp+c/SEiMOnxXN
         s2gF7njtMnW2Y7KZcACinScNonvnPyyFQnYX7Nukrz5FbFnq5yVoZ+06Uv+NhdASWiH7
         Br8g==
X-Gm-Message-State: AJcUukdIUVG55onS3WM1oAvDUW0ie9gzzlNlLFec5LwPbDnZU47bp/xs
        hXViTH3aA5BwKyqul/Xtx7VkseDxG3fSk6uz3IU=
X-Google-Smtp-Source: ALg8bN7Mc0P+j63I1zJ09CUkozKmJP7mspm2ieTO9BRVWqS8XzxQ/B2sP+p1oAC9c/Ci9hyOAuxpXjsHm2uKzdw9oUc=
X-Received: by 2002:a24:648f:: with SMTP id t137mr2222564itc.95.1545408061753;
 Fri, 21 Dec 2018 08:01:01 -0800 (PST)
MIME-Version: 1.0
References: <20181215071451.25752-1-tiny.windzz@gmail.com>
In-Reply-To: <20181215071451.25752-1-tiny.windzz@gmail.com>
From:   Frank Lee <tiny.windzz@gmail.com>
Date:   Sat, 22 Dec 2018 00:00:51 +0800
Message-ID: <CAEExFWsfj2mkoE+EtWqNnWpGGiC9-TNOeyutQg94mMKDZU58DQ@mail.gmail.com>
Subject: Re: [PATCH] sunrpc: convert to DEFINE_SHOW_ATTRIBUTE
To:     Bruce Fields <bfields@fieldses.org>, jlayton@kernel.org,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        davem@davemloft.net
Cc:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please igonre this one.

Thanks
