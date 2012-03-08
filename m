Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:33857 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab2CHOPx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Mar 2012 09:15:53 -0500
Received: by wejx9 with SMTP id x9so344510wej.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Mar 2012 06:15:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1331215742.2472.10.camel@lade.trondhjem.org>
References: <1331163873-2306-1-git-send-email-andros@netapp.com>
	<1331163873-2306-2-git-send-email-andros@netapp.com>
	<1331215742.2472.10.camel@lade.trondhjem.org>
Date: Thu, 8 Mar 2012 09:15:52 -0500
Message-ID: <CAHVgHyWEd0yNKug-umHoUmwjQwvS1UJyLajM0HfimAdiyvi9zA@mail.gmail.com>
Subject: Re: [PATCH V2] NFSv4.1 handle DS stateid errors
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I believe that COMMIT can be called with state == NULL - but looking
at the COMMIT errors, COMMIT should not return stateid errors.

I'll remove the stateid == NULL checks.

-->Andy

On Thu, Mar 8, 2012 at 9:09 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-03-07 at 18:44 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Handle DS READ and WRITE stateid errors by recovering the stateid on the MDS.
>>
>> NFS4ERR_OLD_STATEID is ignored as the client always sends a
>> state sequenceid of zero for DS READ and WRITE stateids.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>  fs/nfs/delegation.c     |    1 +
>>  fs/nfs/nfs4filelayout.c |   33 ++++++++++++++++++++++++++++++++-
>>  fs/nfs/nfs4state.c      |    2 ++
>>  3 files changed, 35 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>> index 87f7544..97d5357 100644
>> --- a/fs/nfs/delegation.c
>> +++ b/fs/nfs/delegation.c
>> @@ -474,6 +474,7 @@ void nfs_remove_bad_delegation(struct inode *inode)
>>               nfs_free_delegation(delegation);
>>       }
>>  }
>> +EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);
>>
>>  /**
>>   * nfs_expire_all_delegation_types
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 47e8f34..cdaee60 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -36,6 +36,7 @@
>>  #include <linux/sunrpc/metrics.h>
>>
>>  #include "internal.h"
>> +#include "delegation.h"
>>  #include "nfs4filelayout.h"
>>
>>  #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>> @@ -86,12 +87,35 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>>                                        struct nfs_client *clp,
>>                                        int *reset)
>>  {
>> +     struct nfs_server *mds_server;
>> +     struct nfs_client *mds_client;
>> +
>>       if (task->tk_status >= 0)
>>               return 0;
>> -
>>       *reset = 0;
>> +     if (state != NULL) {
>
> Why is this test necessary in the first place, BTW? When are you ever
> going to call this function with state == NULL?
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
