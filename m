From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: SQUASHME: missing from FIXME: async layout return
Date: Thu, 13 May 2010 11:17:58 -0400
Message-ID: <AANLkTilhbkde-kAPGSBHT1b8vIZq4cM1SPpI-Rd0iOb7@mail.gmail.com>
References: <4BEBBAE9.8090605@panasas.com>
	 <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8@mail.gmail.com>
	 <4BEC0F78.5060203@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f191.google.com ([209.85.210.191]:55420 "EHLO
	mail-yx0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab0EMPR7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 11:17:59 -0400
Received: by yxe29 with SMTP id 29so384761yxe.4
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 08:17:59 -0700 (PDT)
In-Reply-To: <4BEC0F78.5060203@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 13, 2010 at 10:40 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> On May. 13, 2010, 17:19 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Thu, May 13, 2010 at 4:40 AM, Boaz Harrosh <bharrosh@panasas.com>=
 wrote:
>>> I've tested the patch:
>>> =A0 =A0 =A0 =A0FIXME: async layout return
>>>
>>> And there is a missing small hunk
>>>
>>> I have tested with this patch and it is a very good patch
>>> that should also go into 2.6.33. It is necessary in the rare
>>> case when one inode have more then one open_context.
>>
>> Do you mean more than one open context per open owner?
>
> What we see is one "regular" open context and one which is the layout=
_commit_ctx

Isn't that a BUG?

Here is what we're seeing:

nfs_file_release->nfs_release->nfs_file_clear_open_context->__put_nfs_o=
pen_context->
NFS_PROTO(inode)->close_context->nfs4_close_sync->__nfs4_close->pnfs_la=
youtcommit_inode,

This is the same code that Boaz's 'missing small hunk' adds the wait
to the pnfs_layout_commit_inode to. This is good, because when
__nfs4_close is called with sync, every thing must be sent/returned
prior to the nfs_do_close call.

But there is still a problem. Here is the __nfs4_close call (with out
the wait that Boaz added)

                if (nfsi->layoutcommit_ctx)
                        pnfs_layoutcommit_inode(state->inode, 0);
                if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
                        struct nfs4_pnfs_layout_segment range;

                        range.iomode =3D nfsi->layout.roc_iomode;
                        range.offset =3D 0;
                        range.length =3D NFS4_MAX_UINT64;
                        pnfs_return_layout(state->inode, &range, NULL,
                                           RETURN_FILE);

Note that a pnfs_return_layout which is always 'sync' (async with wait
for completion). So the (currently) async LAYOUTCOMMIT call returns,
and a LAYOUTRETURN is put on the wire

Then the LAYOUTCOMMIT rpc_call_done routine calls
pnfs_layoutcommit_done which calls put_nfs_open_context. If the open
context is different from the open context that was put by
nfs_file_release, then

pnfs_layoutcommit_done->put_nfs_open_context-> ..... ->__nfs4_close
and the return on close LAYOUTRETURN is sent again!

Of couse this second LAYOUTRETURN either gets a zero stateid, or uses
the same stateid as the first LAYOUTRETURN, and the reply to the
second LAYOUTRETURN will result in a NFS4ERR_BAD_STATEID .....

This will occur whether the LAYOUTCOMMIT is async or sync as they both
call pnfs_layoutcommit_done.

I need to understand why there are two open contexts. On the face of
it, it seems wrong.

We also add a pointer to the open context in the nfs_write_data, and
in the pnfs_layoutcommit_data. Do we take a reference on the open data
in theses cases? .

-->Andy



>
> Benny
>
>>
>> -->Andy
>>
>>>
>>> (For some reason I see that happening much more in 2.6.34
>>> =A0I don't understand why)
>>>
>>> Boaz
>>> ---
>>> git diff --stat -p -M
>>> =A0fs/nfs/nfs4state.c | =A0 =A02 +-
>>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>> index 15c8bc8..6dbe893 100644
>>> --- a/fs/nfs/nfs4state.c
>>> +++ b/fs/nfs/nfs4state.c
>>> @@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path, str=
uct nfs4_state *state, fmode_t fm
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D NFS_I(sta=
te->inode);
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nfsi->layoutcommit_ctx)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit_ino=
de(state->inode, 0);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit_ino=
de(state->inode, wait);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (has_layout(nfsi) && nfsi->layout=
=2Eroc_iomode) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs4_pnfs_lay=
out_segment range;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
