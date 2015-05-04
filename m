Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35867 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbEDQYp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:24:45 -0400
Received: by igblo3 with SMTP id lo3so88042835igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:24:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFq8rQYqvwTyz56RjnbhHE2a15jZU1F60tO+ssVxXKbDg@mail.gmail.com>
References: <CAN-5tyHy+M4i2W+coBNXYxz-Ta3grYx=E+3vw7Y9=HE9heGjZQ@mail.gmail.com>
	<CAN-5tyFq8rQYqvwTyz56RjnbhHE2a15jZU1F60tO+ssVxXKbDg@mail.gmail.com>
Date: Mon, 4 May 2015 12:24:44 -0400
Message-ID: <CAN-5tyFof7euZjVYSCaoKhiUq6MoXxiXEHP7JtKKujpOQtjrYA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

Can you provide comments on this patch? Thanks.

On Mon, Apr 27, 2015 at 1:48 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Any comments on this patch?
>
> On Tue, Apr 21, 2015 at 6:36 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR
>> when delegation stateid was used. When no open state exists, in case
>> of application calling truncate() on the file, client has no state to
>> recover and fails with EIO.
>>
>> Instead, upon such error, return the bad delegation and then resend the
>> SETATTR with a zero stateid. In general, when something calls
>> nfs4_handle_exception() with a null state, the operation should be
>> retried after bad delegation is removed.
>>
>> Signed-off: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/nfs4proc.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index ad7cf7e..fbde292 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -360,8 +360,11 @@ static int nfs4_handle_exception(struct
>> nfs_server *server, int errorcode, struc
>>          case -NFS4ERR_DELEG_REVOKED:
>>          case -NFS4ERR_ADMIN_REVOKED:
>>          case -NFS4ERR_BAD_STATEID:
>> -            if (state == NULL)
>> +            if (state == NULL) {
>> +                nfs4_inode_return_delegation(inode);
>> +                exception->retry = 1;
>>                  break;
>> +            }
>>              ret = nfs4_schedule_stateid_recovery(server, state);
>>              if (ret < 0)
>>                  break;
>> --
