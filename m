Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36774 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbbG3I55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 04:57:57 -0400
Received: by pdjr16 with SMTP id r16so21563497pdj.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 01:57:57 -0700 (PDT)
Message-ID: <55B9E708.8020204@gmail.com>
Date: Thu, 30 Jul 2015 16:57:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 4/5] NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
References: <55B763C8.1050408@gmail.com> <CAHQdGtQnHOZAUNyoA1YsbhMYydyycMFN3vop--Bp1N8p6qyf1Q@mail.gmail.com>
In-Reply-To: <CAHQdGtQnHOZAUNyoA1YsbhMYydyycMFN3vop--Bp1N8p6qyf1Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/28/2015 20:47, Trond Myklebust wrote:
> Hi Kinglong,
> 
> On Tue, Jul 28, 2015 at 7:13 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> Client sends a SETATTR request after OPEN for updating attributes.
>> For create file with S_ISGID is set, the SETATTR will be not set S_ISGID
>> as chmod of no PERMISSION.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfs/nfs4proc.c | 2 +-
>>  fs/nfs/nfs4xdr.c  | 4 +---
>>  2 files changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8bee934..801f5f4 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2413,7 +2413,7 @@ static int _nfs4_do_open(struct inode *dir,
>>         state = ctx->state;
>>
>>         if ((opendata->o_arg.open_flags & O_EXCL) &&
>> -           (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
>> +           (opendata->o_arg.createmode == NFS4_CREATE_EXCLUSIVE)) {
>>                 nfs4_exclusive_attrset(opendata, sattr);
>>
>>                 nfs_fattr_init(opendata->o_res.f_attr);
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 558cd65d..b5147bc 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -1382,7 +1382,6 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
>>
>>  static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
>>  {
>> -       struct iattr dummy;
>>         __be32 *p;
>>
>>         p = reserve_space(xdr, 4);
>> @@ -1402,8 +1401,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
>>         case NFS4_CREATE_EXCLUSIVE4_1:
>>                 *p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
>>                 encode_nfs4_verifier(xdr, &arg->u.verifier);
>> -               dummy.ia_valid = 0;
>> -               encode_attrs(xdr, &dummy, arg->label, arg->server);
>> +               encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
>>         }
>>  }
>>
> 
> The problem here is that NFSv4.1 requires that the client use the
> "suppattr_exclcreat" attribute (see
> https://tools.ietf.org/html/rfc5661#section-5.8.1.14 and
> https://tools.ietf.org/html/rfc5661#section-18.16.3) in order to
> figure out which attributes it is permitted to send. If it sends
> anything which is not on the approved list, the server is supposed to
> fail the create attempt with NFS4ERR_INVAL...

Sorry for my missing it.
I will try to implement it later.

thanks,
Kinglong Mee
