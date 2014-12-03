Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:42642 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaLCU7l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 15:59:41 -0500
Received: by mail-vc0-f170.google.com with SMTP id hy4so7375987vcb.15
        for <linux-nfs@vger.kernel.org>; Wed, 03 Dec 2014 12:59:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFpbM5GE2fAcx8uMG6MO2JC-R4ASN_jrnmYH8idie_H+w@mail.gmail.com>
References: <CAN-5tyFpbM5GE2fAcx8uMG6MO2JC-R4ASN_jrnmYH8idie_H+w@mail.gmail.com>
Date: Wed, 3 Dec 2014 15:59:40 -0500
Message-ID: <CAHQdGtSR7HV1vzcAXQRsL1U-FeQuBv7-qNeNVEr35+9+0zcpCw@mail.gmail.com>
Subject: Re: not picking a delegation stateid for IO when delegation stateid
 is being returned
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Wed, Dec 3, 2014 at 2:54 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> I would like an opinion about changing code in such as way that we
> don't select a delegation stateid for an IO operation when this
> particular delegation is being returned.
>
> The reason it's some what problematic is that we send out a
> DELEG_RETURN and then we don't remove the stateid until we receive a
> reply. In the mean while, an IO operation can be happening and in
> nfs4_select_rw_stateid() it sees a delegation stateid and uses it.
> Well, at the server, it finishes processing DELEG_RETURN before
> getting an IO op and by that time the server is finished with the
> stateid and can error an IO operation with BAD_STATEID.
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 7f3f606..4f6f6c9 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -854,7 +854,8 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid
> *dst, struct inode *in
>         flags &= FMODE_READ|FMODE_WRITE;
>         rcu_read_lock();
>         delegation = rcu_dereference(nfsi->delegation);
> -       ret = (delegation != NULL && (delegation->type & flags) == flags);
> +       ret = (delegation != NULL && (delegation->type & flags) == flags &&
> +               !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags));
>         if (ret) {
>                 nfs4_stateid_copy(dst, &delegation->stateid);
>                 nfs_mark_delegation_referenced(delegation);

The above cannot eliminate the possibility that we won't use a
delegation while it is being returned. It will at best just reduce the
window of opportunity.

So, why is this being considered to be a problem in the first place?
Are you seeing a measurable performance impact on a real life workload
(as opposed to some 1-in-a-billion occurrence from a QA test :-))?

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
