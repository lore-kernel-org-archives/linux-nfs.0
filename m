From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix bug nfslock request sending fail will be process
 as blocked
Date: Tue, 16 Mar 2010 09:12:42 -0400
Message-ID: <1268745162.3155.17.camel@localhost.localdomain>
References: <4B9A14A1.3000008@cn.fujitsu.com>
	 <1268401329.3156.12.camel@localhost.localdomain>
	 <4B9F5B55.2020902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49356 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756638Ab0CPNMy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 09:12:54 -0400
In-Reply-To: <4B9F5B55.2020902@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-03-16 at 18:20 +0800, Mi Jinlong wrote:=20
>=20
> Trond Myklebust =E5=86=99=E9=81=93:
> > On Fri, 2010-03-12 at 18:17 +0800, Mi Jinlong wrote:=20
> >> If local reason cause nfslock request send fail(means status < 0,
> >> resp->status not be reset), the request will be process as blocked=
=20
> >> at first now.
> >>
> >> This patch initialize resp->status to nlm_lck_denied_nolocks, it=20
> >> can make the following process correctly.
> >>
> >> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >> ---
> >>  fs/lockd/clntproc.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> >> index c81249f..a631582 100644
> >> --- a/fs/lockd/clntproc.c
> >> +++ b/fs/lockd/clntproc.c
> >> @@ -535,7 +535,7 @@ again:
> >>  	 * Initialise resp->status to a valid non-zero value,
> >>  	 * since 0 =3D=3D nlm_lck_granted
> >>  	 */
> >> -	resp->status =3D nlm_lck_blocked;
> >> +	resp->status =3D nlm_lck_denied_nolocks;
> >>  	for(;;) {
> >>  		/* Reboot protection */
> >>  		fl->fl_u.nfs_fl.state =3D host->h_state;
> >=20
> > We _want_ to process it as being blocked if the RPC call was
> > interrupted. The above patch will cause the client to just abandon =
the
> > interrupted lock request without sending the CANCEL request...
>=20
>   No, the above patch don't just abandon the interrupted lock request=
,
>   when the RPC call was interrupted, client will send an UNLOCK reque=
st for status < 0.
>    ...
>    583         if (status < 0)
>    584                 goto out_unlock;
>    ...
>=20
>   And, I think an UNLOCK request is more advisable than a CANCEL requ=
est.
>   If a LOCK request was succeed when CANCEL request coming, it's usel=
ess;
>   the lock should be unlocked.

An unlock does not guarantee that the server will cancel the blocked
lock request.

Trond

