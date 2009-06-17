From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 21:39:29 -0400
Message-ID: <89c397150906161839u5c7c44f7pa14abfc1e5d7dc81@mail.gmail.com>
References: <1245115172-7030-1-git-send-email-bhalevy@panasas.com>
	 <20090616204734.GE3045@fieldses.org>
	 <89c397150906161815v6136e000t338f4fce10ceff23@mail.gmail.com>
	 <20090617012514.GE8980@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:55838 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbZFQBrp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 21:47:45 -0400
Received: by mail-gx0-f214.google.com with SMTP id 10so37462gxk.13
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2009 18:47:48 -0700 (PDT)
In-Reply-To: <20090617012514.GE8980@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 9:25 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Tue, Jun 16, 2009 at 09:15:32PM -0400, William A. (Andy) Adamson wrote:
>> On Tue, Jun 16, 2009 at 4:47 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
>> > On Tue, Jun 16, 2009 at 04:19:32AM +0300, Benny Halevy wrote:
>> >> From: Andy Adamson <andros@netapp.com>
>> >>
>> >> Replay processing needs to preceed other error processing.
>> >
>> > Why?
>> >
>>
>> Section 18.36.4. (CREATE_SESSION implementation section) states the
>> ordering of clientid confirmation processing as
>> 1) client id record lookup
>> 2) sequence id processing
>> 3) client id confirmation
>>
>> rpc cred processing is done in #3.
>
> I don't see any reason we can't check the cred earlier--let's just leave
> this as is and drop this patch.

you want to replace the cache with this error?  I think at the very
least you need to goto out instead of out_cache.

note that a replay of a CREATE_SESSION on an unconfirmed clientid
returns NFS4ERR_SEQMISORDERED. So it doesn't matter at all what the
rpc_cred is.

The choice is between an NFS4ERR_SEQMISORDERED and NFS4ERR_CLIDINUSE.

I think the patch should stay.

-->Andy
>
> --b.
>
>>
>> ->Andy
>>
>> > --b.
>> >
>> >>
>> >> Signed-off-by: Andy Adamson <andros@netapp.com>
>> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> >> ---
>> >>  fs/nfsd/nfs4state.c |   12 ++++++------
>> >>  1 files changed, 6 insertions(+), 6 deletions(-)
>> >>
>> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> >> index bfc808b..5aef525 100644
>> >> --- a/fs/nfsd/nfs4state.c
>> >> +++ b/fs/nfsd/nfs4state.c
>> >> @@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>> >>               }
>> >>               conf->cl_slot.sl_seqid++;
>> >>       } else if (unconf) {
>> >> -             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>> >> -                 (ip_addr != unconf->cl_addr)) {
>> >> -                     status = nfserr_clid_inuse;
>> >> -                     goto out_cache;
>> >> -             }
>> >> -
>> >>               slot = &unconf->cl_slot;
>> >>               status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
>> >>               if (status) {
>> >> @@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>> >>                       goto out;
>> >>               }
>> >>
>> >> +             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>> >> +                 (ip_addr != unconf->cl_addr)) {
>> >> +                     status = nfserr_clid_inuse;
>> >> +                     goto out_cache;
>> >> +             }
>> >> +
>> >>               slot->sl_seqid++; /* from 0 to 1 */
>> >>               move_to_confirmed(unconf);
>> >>
>> >> --
>> >> 1.6.3
>> >>
>> > _______________________________________________
>> > pNFS mailing list
>> > pNFS@linux-nfs.org
>> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>> >
>
