From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug nfslock request sending fail will be process
 as blocked
Date: Tue, 16 Mar 2010 18:20:05 +0800
Message-ID: <4B9F5B55.2020902@cn.fujitsu.com>
References: <4B9A14A1.3000008@cn.fujitsu.com> <1268401329.3156.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59610 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S966062Ab0CPKSl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Mar 2010 06:18:41 -0400
In-Reply-To: <1268401329.3156.12.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust =E5=86=99=E9=81=93:
> On Fri, 2010-03-12 at 18:17 +0800, Mi Jinlong wrote:=20
>> If local reason cause nfslock request send fail(means status < 0,
>> resp->status not be reset), the request will be process as blocked=20
>> at first now.
>>
>> This patch initialize resp->status to nlm_lck_denied_nolocks, it=20
>> can make the following process correctly.
>>
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  fs/lockd/clntproc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>> index c81249f..a631582 100644
>> --- a/fs/lockd/clntproc.c
>> +++ b/fs/lockd/clntproc.c
>> @@ -535,7 +535,7 @@ again:
>>  	 * Initialise resp->status to a valid non-zero value,
>>  	 * since 0 =3D=3D nlm_lck_granted
>>  	 */
>> -	resp->status =3D nlm_lck_blocked;
>> +	resp->status =3D nlm_lck_denied_nolocks;
>>  	for(;;) {
>>  		/* Reboot protection */
>>  		fl->fl_u.nfs_fl.state =3D host->h_state;
>=20
> We _want_ to process it as being blocked if the RPC call was
> interrupted. The above patch will cause the client to just abandon th=
e
> interrupted lock request without sending the CANCEL request...

  No, the above patch don't just abandon the interrupted lock request,
  when the RPC call was interrupted, client will send an UNLOCK request=
 for status < 0.
   ...
   583         if (status < 0)
   584                 goto out_unlock;
   ...

  And, I think an UNLOCK request is more advisable than a CANCEL reques=
t.
  If a LOCK request was succeed when CANCEL request coming, it's useles=
s;
  the lock should be unlocked.

  That's only my opinion.

thanks,
Mi Jinlong

