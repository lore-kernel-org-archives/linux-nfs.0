From: Ni Wenjuan <niwj@cn.fujitsu.com>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Fri, 20 Mar 2009 11:58:55 +0800
Message-ID: <49C3147F.5030009@cn.fujitsu.com>
References: <49C193B1.8040608@cn.fujitsu.com> <20090319194722.GA5499@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63135 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbZCTD7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 23:59:38 -0400
In-Reply-To: <20090319194722.GA5499@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields =E5=86=99=E9=81=93:
> On Thu, Mar 19, 2009 at 08:37:05AM +0800, Ni Wenjuan wrote:
>> Fix a test in rename operation. rename dir1 into existing,nonempty d=
ir2 should
>> return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPTY. RFC says if the =
target is a
>> directory but not empty, the server will return the error, NFS4ERR_E=
XIST.
>=20
> On a second look: could you double-check the client behavior?:
> Currently
>=20
> 	mkdir subdir
> 	mkdir -p todir/subdir
> 	touch todir/subdir/foo
> 	mv subdir todir/
>=20
> results (as in the local case) in "Directory not empty".  What happen=
s
> after applying this patch?
>=20
> --b.

before patch,  if you execute "mv subdir todir/"  ,client (as in the lo=
cal case)=20
will notices you that cannot move 'subdir' to a subdirectory of itself=20
,'todir/subdie'.

after applying patch, if you execute "mv subdir todir/"  ,it will notic=
es you=20
that can't move 'subdir to todir/subdir' :File exists .


>=20
>> Signed-off-by:Ni Wenjuan  <niwj@cn.fujitsu.com>
>>
>> ---
>>  fs/nfsd/nfs4proc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 9fa60a3..c1e2e22 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -605,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct
>> nfsd4_compound_state *cstate,
>>
>>  	/* the underlying filesystem returns different error's than requir=
ed
>>  	 * by NFSv4. both save_fh and current_fh have been verified.. */
>> -	if (status =3D=3D nfserr_isdir)
>> +	if (status =3D=3D nfserr_isdir || status =3D=3D nfserr_notempty)
>>  		status =3D nfserr_exist;
>>  	else if ((status =3D=3D nfserr_notdir) &&
>>                    (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mo=
de) &&
>> --=20
>>
>=20
>=20


