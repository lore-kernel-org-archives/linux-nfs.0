From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Wed, 10 Aug 2011 14:11:31 -0400
Message-ID: <4E42C9D3.2070006@netapp.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com> <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com> <4E40F53A.2080303@tonian.com> <CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Benny Halevy <bhalevy@tonian.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Billy Hass <billdh16@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704Ab1HJSLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Aug 2011 14:11:34 -0400
In-Reply-To: <CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2011 01:29 PM, Billy Hass wrote:
> On Tue, Aug 9, 2011 at 4:52 AM, Benny Halevy <bhalevy@tonian.com> wro=
te:
>> On 2011-08-08 15:01, Olga Kornievskaia wrote:
>>> I'd like to 2nd this.
>>>
>>> Current pnfs server doesn't build if chosen to be build into the
>>> kernel. It does build, if built as a module.
>>>
>>> when client and server code is build into the kernel it seems that
>>> both sides try to define pnfs_roc() function and stepping on each
>>> others toes..
>>>
>>> On Fri, Aug 5, 2011 at 9:58 PM, Billy Hass <billdh16@gmail.com> wro=
te:
>>>> Hey all,
>>>>
>>>> I am unable to compile the latest kernel from the git tree.
>>>>
>>>> git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
>>>> cd linux-pnfs
>>>> make oldconfig
>>>> make -j5 -s
>>>>      [ ... ]
>>>>      [A lot of warnings, but no errors]
>>>>      [ ... ]
>>>> make install
>>>>      sh /usr/src/kernels/3.0.0/linux-
>>>>     pnfs/arch/x86/boot/install.sh 3.0.0-pnfs arch/x86/boot/bzImage=
 \
>>>>          System.map "/boot"
>>>>       *** Missing file: arch/x86/boot/bzImage
>>>>       *** You need to run "make" before "make install".
>>>>      make[1]: *** [install] Error 1
>>>>      make: *** [install] Error 2
>>>>
>>>> When I try to do the make again, here is the output
>>>> make -j5 -s
>>>>      fs/nfsd/built-in.o: In function `pnfs_roc':
>>>>      (.text+0x226d1): multiple definition of `pnfs_roc'
>>>>      fs/nfs/built-in.o:(.text+0x304ee): first defined here
>>>>      make[1]: *** [fs/built-in.o] Error 1
>>>>      make: *** [fs] Error 2
>>>>      make: *** Waiting for unfinished jobs....
>>>>
>>>> Thanks for any help!
>>>>
>>>> Bill
>>>>
>>>> --
>>>> Bill D. Hass
>>>> Major | Electrical Engineering BSE
>>>> Minor | Mathematics
>>>> University of Michigan '13
>>>> College of Engineering
>>>> (715) 923-8382
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> Right.  The following patch simply renames the function for pnfsd.
>> I'm pushing it to pnfs-all-3.0 and I'll add it to the 3.1-rc tree
>> (pnfs-all-latest) once I finish rebasing and testing it.
>>
>> Benny
>>
>> From d76f73eca38fd7b803d80e78cfa8f9468e83a9b3 Mon Sep 17 00:00:00 20=
01
>> From: Benny Halevy <benny@tonian.com>
>> Date: Tue, 9 Aug 2011 01:11:16 -0400
>> Subject: [PATCH] SQUASHME: pnfsd: rename pnfs_roc to pnfsd_roc
>>
>> It clashes with a function called the same in the nfs module
>>
>> Signed-off-by: Benny Halevy <benny@tonian.com>
>> ---
>>  fs/nfsd/nfs4pnfsd.c |    2 +-
>>  fs/nfsd/nfs4state.c |    2 +-
>>  fs/nfsd/pnfsd.h     |    2 +-
>>  3 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
>> index b1f67eb..e0669ad 100644
>> --- a/fs/nfsd/nfs4pnfsd.c
>> +++ b/fs/nfsd/nfs4pnfsd.c
>> @@ -1336,7 +1336,7 @@ nomatching_layout(struct nfs4_layoutrecall *cl=
r)
>>  *   the layout and simulate a layout_return. Surly the client has f=
orgotten
>>  *   these layouts or it would return them before the close.
>>  */
>> -void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp)
>> +void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
>>  {
>>        struct nfs4_layout *lo, *nextlp;
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 1941051..b95589e 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -3620,7 +3620,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfs=
d4_compound_state *cstate,
>>        update_stateid(&stp->st_stateid);
>>        memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t=
));
>>
>> -       pnfs_roc(stp->st_stateowner->so_client, stp->st_file);
>> +       pnfsd_roc(stp->st_stateowner->so_client, stp->st_file);
>>
>>        /* release_stateid() calls nfsd_close() if needed */
>>        release_open_stateid(stp);
>> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
>> index a4c8a9c..6e60d2c 100644
>> --- a/fs/nfsd/pnfsd.h
>> +++ b/fs/nfsd/pnfsd.h
>> @@ -125,7 +125,7 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_st=
ate *);
>>  void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *)=
;
>>  int put_layoutrecall(struct nfs4_layoutrecall *);
>>  void nomatching_layout(struct nfs4_layoutrecall *);
>> -void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp);
>> +void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
>>  void *layoutrecall_done(struct nfs4_layoutrecall *);
>>  void nfsd4_cb_layout(struct nfs4_layoutrecall *);
>>  int _nfsd_layout_recall_cb(struct super_block *, struct inode *,
>> --
>> 1.7.6
>>
>>
>=20
> I updated to the latest git today and I am still having trouble compi=
ling.
>=20
> [root@pdsi8 linux-pnfs]# make -j5 -s
> [...]
> drivers/isdn/hardware/mISDN/hfcpci.c:2319:2: warning: ignoring return
> value of =91driver_for_each_device=92, declared with attribute
> warn_unused_result [-Wunused-result]
> drivers/isdn/hardware/eicon/message.c: In function =91mixer_notify_up=
date=92:
> drivers/isdn/hardware/eicon/message.c:11308:54: warning: array
> subscript is above array bounds [-Warray-bounds]
> fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
> function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
> cc1: some warnings being treated as errors
> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
> make[1]: *** [fs/xfs] Error 2
> make: *** [fs] Error 2
> make: *** Waiting for unfinished jobs....
> In file included from drivers/message/i2o/config-osm.c:39:0:
> drivers/message/i2o/i2o_config.c: In function =91i2o_cfg_passthru=92:
> [...]
>=20
> [root@pdsi8 linux-pnfs]# make modules && make modules_install && make=
 install
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CC [M]  fs/xfs/linux-2.6/xfs_iops.o
> fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
> function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
> cc1: some warnings being treated as errors
> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
> make[1]: *** [fs/xfs] Error 2
> make: *** [fs] Error 2

This looks like an XFS problem now... did you see if any of the NFS cod=
e compiled this time?

I've had these issues before, and it's usually caused by something in m=
y .config.  Generating a new one usually fixes it for me.

- Bryan

>=20
> Here is my second make after a failed make:
> [root@pdsi8 linux-pnfs]# make -j5 -s
> fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
> function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
> cc1: some warnings being treated as errors
> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
> make[1]: *** [fs/xfs] Error 2
> make: *** [fs] Error 2
> make: *** Waiting for unfinished jobs....
>=20
>=20

