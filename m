Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760785AbbKTQ4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 11:56:13 -0500
Date: Fri, 20 Nov 2015 11:56:11 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4: start callback_ident at idr 1
In-Reply-To: <CAHQdGtTTqDtg==fK_2t7dOOh_54tDf84Hov2+D6Ciy=YvhzyoQ@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1511201147450.34561@planck.local>
References: <da06a514114528e639923b8ef26c0e815e91554f.1448031050.git.bcodding@redhat.com> <CAHQdGtTTqDtg==fK_2t7dOOh_54tDf84Hov2+D6Ciy=YvhzyoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 20 Nov 2015, Trond Myklebust wrote:

> Hi Ben,
>
> On Fri, Nov 20, 2015 at 9:56 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> >
> > If clp->cl_cb_ident is zero, then nfs_cb_idr_remove_locked() skips removing
> > it when the nfs_client is freed.  A decoding or server bug can then find
> > and try to put that first nfs_client which would lead to a crash.
>
> Thanks for fixing!
> Have you ever seen such a crash in the wild? IOW: is this something we
> should consider for stable?

Yes, there's a server that sometimes sends truncated cb_compounds, and this
bug is hit if we continue decoding 0's past the end of received data since
cb_ident ends up being 0.  Both fixes I sent today are trying to handle that
particular behavior.

Ben
