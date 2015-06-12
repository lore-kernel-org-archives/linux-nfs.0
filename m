Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f46.google.com ([209.85.216.46]:36609 "EHLO
	mail-vn0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbbFLShE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 14:37:04 -0400
Received: by vnbg1 with SMTP id g1so7372464vnb.3
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 11:37:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434133855-86259-1-git-send-email-kolga@netapp.com>
References: <1434133855-86259-1-git-send-email-kolga@netapp.com>
Date: Fri, 12 Jun 2015 14:37:03 -0400
Message-ID: <CAHQdGtTSzfHL8WaMXRN+vVmUuTQ6a8w71zFpkutTkaVgAG_TYQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Fri, Jun 12, 2015 at 2:30 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
> delegation stateid was used. When no open state exists, in case of application
> calling truncate() on the file, client has no state to recover and fails with
> EIO.
>
> Instead, upon such error, return the bad delegation and then resend the
> SETATTR with a zero stateid.
>
> Signed-off: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/delegation.h | 6 ++++++
>  fs/nfs/nfs4proc.c   | 7 ++++++-
>  2 files changed, 12 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> index e3c20a3..e37165f 100644
> --- a/fs/nfs/delegation.h
> +++ b/fs/nfs/delegation.h
> @@ -62,6 +62,12 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
>  int nfs4_have_delegation(struct inode *inode, fmode_t flags);
>  int nfs4_check_delegation(struct inode *inode, fmode_t flags);
>
> +static inline int nfs4_have_any_delegation(struct inode *inode)
> +{
> +       struct nfs_inode *nfsi = NFS_I(inode);
> +       return rcu_access_pointer(nfsi->delegation) ? 1 : 0;
> +}

What would this do that isn't already covered by
nfs4_have_delegation(inode, FMODE_READ)?

Cheers
  Trond
