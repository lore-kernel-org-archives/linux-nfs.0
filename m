Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f49.google.com ([209.85.216.49]:41667 "EHLO
	mail-vn0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbbDHRBz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 13:01:55 -0400
Received: by vnbg190 with SMTP id g190so13242628vnb.8
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 10:01:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Wed, 8 Apr 2015 13:01:54 -0400
Message-ID: <CAHQdGtSFqzfSc32quaSgok3Z4VjXgq9isBNfvKzPgA9cfCTTEw@mail.gmail.com>
Subject: Re: [PATCH 0/2] Mountstats Fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 8, 2015 at 12:47 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> I had some trouble using mountstats to analyze READ_PLUS operations, so I
> wrote these patches to fix my issues.
>
> I found that /proc/self/mountstats was reporting "GETDEVICELIST" as "51",

Shouldn't we try to fix that as being a regression in the client? I
see no reason why we shouldn't be able to add in a p_name for
GETDEVICELIST.

> most likely because it was removed from the client but the nfs4_procedures
> array still has a placeholder for it.  Mountstats crashes when it tries to
> analyze "51", so the second patch fixes this issue by looking for numeric
> operation names.  I'm willing to put in stubs for GETDEVICELIST back into
> the client if that would be a better fix.
>
> Thanks,
> Anna
>
>
> Anna Schumaker (2):
>   mountstats: Resync NFSv4 Operations List
>   mountstats: Only count operations that have names
>
>  tools/mountstats/mountstats.py | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
>
> --
> 2.3.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
