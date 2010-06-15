From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 07/10] pnfs-submit: avoid race handling return on close
Date: Tue, 15 Jun 2010 13:52:48 -0400
Message-ID: <AANLkTimScICltrCrtEIz7qw1GzuaTGNwCVTk-ZTsZO4_@mail.gmail.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
	<1276566375-24566-2-git-send-email-iisaman@netapp.com>
	<1276566375-24566-3-git-send-email-iisaman@netapp.com>
	<1276566375-24566-4-git-send-email-iisaman@netapp.com>
	<1276566375-24566-5-git-send-email-iisaman@netapp.com>
	<1276566375-24566-6-git-send-email-iisaman@netapp.com>
	<1276566375-24566-7-git-send-email-iisaman@netapp.com>
	<1276566375-24566-8-git-send-email-iisaman@netapp.com>
	<4C17B304.4070308@panasas.com>
	<AANLkTilDj2Ua_t77kk5Gj_t0vqEcOJFKlqODAj18KQnm@mail.gmail.com>
	<1276623230.8767.48.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35904 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab0FORwu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 13:52:50 -0400
Received: by bwz7 with SMTP id 7so2828763bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:52:48 -0700 (PDT)
In-Reply-To: <1276623230.8767.48.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 15, 2010 at 1:33 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Tue, 2010-06-15 at 13:32 -0400, Fred Isaman wrote:
>> On Tue, Jun 15, 2010 at 1:06 PM, Benny Halevy <bhalevy@panasas.com> =
wrote:
>> > On Jun. 14, 2010, 21:46 -0400, Fred Isaman <iisaman@netapp.com> wr=
ote:
>> >> This prepares for the next patch.
>> >>
>> >> NOTE this doesn't really fix any current race, since
>> >> layout going to NULL is OK. =A0But layout changing from NULL to n=
onNULL
>> >> is a real race that is not fixed
>> >>
>> >> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> >> ---
>> >> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 =A05 +++--
>> >> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 +++++++++++
>> >> =A0include/linux/nfs4_pnfs.h | =A0 =A02 ++
>> >> =A03 files changed, 16 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> >> index d5144bd..8a7a64c 100644
>> >> --- a/fs/nfs/nfs4state.c
>> >> +++ b/fs/nfs/nfs4state.c
>> >> @@ -594,11 +594,12 @@ static void __nfs4_close(struct path *path,=
 struct nfs4_state *state,
>> >> =A0 =A0 =A0 } else {
>> >> =A0#ifdef CONFIG_NFS_V4_1
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(stat=
e->inode);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 int roc =3D nfs4_roc_iomode(nfsi);
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 if (has_layout(nfsi) && nfsi->layout.ro=
c_iomode) {
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (roc) {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_layo=
ut_segment range;
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.iomode =3D nfsi->=
layout.roc_iomode;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.iomode =3D roc;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.offset =3D 0;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.length =3D NFS4=
_MAX_UINT64;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(st=
ate->inode, &range, NULL,
>> >> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> >> index 6def09c..bd11ec7 100644
>> >> --- a/fs/nfs/pnfs.c
>> >> +++ b/fs/nfs/pnfs.c
>> >> @@ -321,6 +321,17 @@ pnfs_unregister_layoutdriver(struct pnfs_lay=
outdriver_type *ld_type)
>> >> =A0#define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
>> >> =A0#endif /* CONFIG_SMP */
>> >>
>> >> +int nfs4_roc_iomode(struct nfs_inode *nfsi)
>> >> +{
>> >> + =A0 =A0 int rv =3D 0;
>> >> +
>> >> + =A0 =A0 spin_lock(&pnfs_spinlock);
>> >
>> > Why take the global lock rather than nfsi->lo_lock?
>> >
>> > Benny
>>
>> You are right. That would be a copy-paste error.
>
> What's an nfsi->lo_lock, and why do we need one?
>
> Trond
>
>

It protects nfsi->layout and its contents.

=46red
