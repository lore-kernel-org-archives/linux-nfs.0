From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug nfslock request sending fail will be process
 as blocked
Date: Wed, 17 Mar 2010 18:03:53 +0800
Message-ID: <4BA0A909.4030004@cn.fujitsu.com>
References: <4B9A14A1.3000008@cn.fujitsu.com>	 <1268401329.3156.12.camel@localhost.localdomain>	 <4B9F5B55.2020902@cn.fujitsu.com> <1268745162.3155.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54898 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab0CQKCo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 06:02:44 -0400
In-Reply-To: <1268745162.3155.17.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust =E5=86=99=E9=81=93:
> On Tue, 2010-03-16 at 18:20 +0800, Mi Jinlong wrote:=20
>> Trond Myklebust =E5=86=99=E9=81=93:
>>> On Fri, 2010-03-12 at 18:17 +0800, Mi Jinlong wrote:=20
>>>> If local reason cause nfslock request send fail(means status < 0,
>>>> resp->status not be reset), the request will be process as blocked=
=20
>>>> at first now.
>>>>
>>>> This patch initialize resp->status to nlm_lck_denied_nolocks, it=20
>>>> can make the following process correctly.
>>>>
>>>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>>>> ---
>>>>  fs/lockd/clntproc.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>>>> index c81249f..a631582 100644
>>>> --- a/fs/lockd/clntproc.c
>>>> +++ b/fs/lockd/clntproc.c
>>>> @@ -535,7 +535,7 @@ again:
>>>>  	 * Initialise resp->status to a valid non-zero value,
>>>>  	 * since 0 =3D=3D nlm_lck_granted
>>>>  	 */
>>>> -	resp->status =3D nlm_lck_blocked;
>>>> +	resp->status =3D nlm_lck_denied_nolocks;
>>>>  	for(;;) {
>>>>  		/* Reboot protection */
>>>>  		fl->fl_u.nfs_fl.state =3D host->h_state;
>>> We _want_ to process it as being blocked if the RPC call was
>>> interrupted. The above patch will cause the client to just abandon =
the
>>> interrupted lock request without sending the CANCEL request...
>>   No, the above patch don't just abandon the interrupted lock reques=
t,
>>   when the RPC call was interrupted, client will send an UNLOCK requ=
est for status < 0.
>>    ...
>>    583         if (status < 0)
>>    584                 goto out_unlock;
>>    ...
>>
>>   And, I think an UNLOCK request is more advisable than a CANCEL req=
uest.
>>   If a LOCK request was succeed when CANCEL request coming, it's use=
less;
>>   the lock should be unlocked.
>=20
> An unlock does not guarantee that the server will cancel the blocked
> lock request.

  When server receive an UNLOCK request, it will try to cancel the lock=
 at first,
  codes as follows:
    ...
    567 nlmsvc_unlock(struct nlm_file *file, struct nlm_lock *lock)
    568 {
    ....
    578         /* First, cancel any lock that might be there */
    579         nlmsvc_cancel_blocked(file, lock);
    ...

  Server don't process the nlmsvc_cancel_blocked's return value, is it =
the problem=20
  that you said above ? or some other reason?

  Server cannot cancel the blocked lock request, it's acceptable someti=
mes, IMO,
  but client should work strongly itself.

thanks,
Mi Jinlong

