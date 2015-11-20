Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <da06a514114528e639923b8ef26c0e815e91554f.1448031050.git.bcodding@redhat.com>
References: <da06a514114528e639923b8ef26c0e815e91554f.1448031050.git.bcodding@redhat.com>
Date: Fri, 20 Nov 2015 11:46:35 -0500
Message-ID: <CAHQdGtTTqDtg==fK_2t7dOOh_54tDf84Hov2+D6Ciy=YvhzyoQ@mail.gmail.com>
Subject: Re: [PATCH] nfs4: start callback_ident at idr 1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On Fri, Nov 20, 2015 at 9:56 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
>
> If clp->cl_cb_ident is zero, then nfs_cb_idr_remove_locked() skips removing
> it when the nfs_client is freed.  A decoding or server bug can then find
> and try to put that first nfs_client which would lead to a crash.

Thanks for fixing!
Have you ever seen such a crash in the wild? IOW: is this something we
should consider for stable?

Cheers
  Trond
