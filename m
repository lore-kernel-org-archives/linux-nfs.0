Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:46532 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbaIXPI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 11:08:28 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so6675936igb.9
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 08:08:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5422CB4E.1070000@Netapp.com>
References: <CAN-5tyFQihuK22n_bzsO0LtqQBM+KW6vELt7H_DPEF0RFdoDQQ@mail.gmail.com>
	<5422CB4E.1070000@Netapp.com>
Date: Wed, 24 Sep 2014 11:08:27 -0400
Message-ID: <CAN-5tyFUOGejnf2tmAtZmHumRV8DH2EdcoerJx5x8YkENTcsNA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing lease renewal
From: Olga Kornievskaia <aglo@umich.edu>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I did. Let me try again.

On Wed, Sep 24, 2014 at 9:46 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hey Olga,
>
> Your patch is using spaces instead of tabs, so it won't apply to the existing code.  Did you use `git format-patch` to generate it?
>
> Anna
>
> On 09/24/2014 09:11 AM, Olga Kornievskaia wrote:
>> Commit c9fdeb28 removed a 'continue' after checking if the lease needs
>> to be renewed. However, if client hasn't moved, the code falls down to
>> starting reboot recovery erroneously (ie., sends open reclaim and gets
>> back stale_clientid error) before recovering from getting stale_clientid
>> on the renew operation.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/nfs4state.c |    4 +++-
>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 22fe351..4616598 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -2340,11 +2340,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
>>                         continue;
>>                 }
>>
>> -               if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>> +               if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state) &&
>> +                    test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
>>                         section = "check lease";
>>                         status = nfs4_check_lease(clp);
>>                         if (status < 0)
>>                                 goto out_error;
>> +                       continue;
>>                 }
>>
>>                 if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
>
