Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:41962 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbeDNMcu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Apr 2018 08:32:50 -0400
Received: by mail-vk0-f46.google.com with SMTP id i75so2112548vke.8
        for <linux-nfs@vger.kernel.org>; Sat, 14 Apr 2018 05:32:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180414072202.GA6514@infradead.org>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Sat, 14 Apr 2018 08:32:48 -0400
Message-ID: <CAN-5tyGDJUV6wVWoLoEy8V=RM+cF+y_JT-UkrG+7rcHv1VzgmQ@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 14, 2018 at 3:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> What is the use case for adding all these crazy complications?

We have already provided evidence for improved performance of
asynchronous copy vs synchronous copy. This is also foundation for the
"inter" server-to-server copy which is coming later as it was decided
to add the support in parts.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
