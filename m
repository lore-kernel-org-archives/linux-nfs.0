Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:37043 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754076AbeBBTuE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 14:50:04 -0500
Received: by mail-vk0-f50.google.com with SMTP id g83so14185788vki.4
        for <linux-nfs@vger.kernel.org>; Fri, 02 Feb 2018 11:50:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180126213405.GA7770@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-6-kolga@netapp.com>
 <20180126213405.GA7770@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 2 Feb 2018 14:50:01 -0500
Message-ID: <CAN-5tyE0j5xOyagWH+zgzFc9Hd00=k=3-J_Nuych_9OGG3-CyA@mail.gmail.com>
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 26, 2018 at 4:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> If I understand correctly (I may be wrong), once this patch is applied a
> COPY may fail that previously worked--because we're switching over to
> the asynchronous copy implementation before it's actually complete.

I will have to double check this with testing but I think after this
patch the asynchronous copy is functional but doesn't comply with the
spec (eg., doesn't generate the unique stateid).

> Of course, that's fixed by the end of this series.  But we try to avoid
> that situation, where functionality is temporarily broken in the middle
> of a patch series and then fixed later.
>
> Options might be to squash this patch together with some of the later
> patches.  Or go ahead and add this code but don't actually enable it
> till later.  (E.g. arrange that the "if (!copy->cp_synchronous)" case
> won't be taken till the last patch.  Maybe it already works that way, I
> can't tell.)  Or maybe there's some slicker way that I don't see right
> now.

I could do if (!copy->cp_synchronous && 0) and then add a patch that removes 0.

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
