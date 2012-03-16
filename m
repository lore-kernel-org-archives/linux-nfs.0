Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:52255 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760812Ab2CPPFS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 11:05:18 -0400
Received: by wejx9 with SMTP id x9so4001947wej.19
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 08:05:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331858152.24392.12.camel@lade.trondhjem.org>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
	<1331836850-5195-12-git-send-email-andros@netapp.com>
	<1331858152.24392.12.camel@lade.trondhjem.org>
Date: Fri, 16 Mar 2012 11:05:17 -0400
Message-ID: <CAHVgHyWxfH=9hbp0-NecBjbgfAwCMKBzv4oa5NOy_cJC8Pa6RQ@mail.gmail.com>
Subject: Re: [PATCH Version 1 11/11] NFSv4.1 de reference a disconnected data
 server client record
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 15, 2012 at 8:35 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> When the last DS io is processed, the data server client record will be
>> freed.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c    |    4 ++++
>>  fs/nfs/nfs4filelayout.h    |    1 +
>>  fs/nfs/nfs4filelayoutdev.c |   17 +++++++++++++++++
>>  3 files changed, 22 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 4c846cb..28b71bf 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -209,10 +209,12 @@ static int filelayout_read_done_cb(struct rpc_task *task,
>>                       reset, data->ds_clp, data->ds_clp->cl_session);
>>
>>               if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
>> +                     struct nfs_client *clp = data->ds_clp;
>>                       filelayout_reset_read(task, data);
>>                       if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
>>                               filelayout_mark_devid_invalid(devid);
>>                               rpc_drain_queue(&tbl->slot_tbl_waitq);
>> +                             nfs4_ds_disconnect(clp);
>>                       }
>>               }
>>               rpc_restart_call_prepare(task);
>> @@ -310,10 +312,12 @@ static int filelayout_write_done_cb(struct rpc_task *task,
>>                       reset, data->ds_clp, data->ds_clp->cl_session);
>>
>>               if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
>> +                     struct nfs_client *clp = data->ds_clp;
>>                       filelayout_reset_write(task, data);
>>                       if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
>>                               filelayout_mark_devid_invalid(devid);
>>                               rpc_drain_queue(&tbl->slot_tbl_waitq);
>> +                             nfs4_ds_disconnect(clp);
>
> What guarantees at this point that all the RPC calls have terminated?

That is not the intention of the call to nfs4_ds_disconnect.

What is guaranteed is:

1) there are no more new calls using the DS session due to the invalid deviceid.
2) all calls (including outstanding calls) have a reference to the DS nfs_client
3) once the last outstanding call has been processed and it's
nfs_put_client has been called, because of the nfs_put_client call in
nfs4_ds_disconnect, the DS nfs_client is freed.


>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
