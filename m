From: Billy Hass <billdh16@gmail.com>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Wed, 10 Aug 2011 13:29:33 -0400
Message-ID: <CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A@mail.gmail.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com>
	<CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com>
	<4E40F53A.2080303@tonian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@tonian.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34840 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab1HJR3e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 13:29:34 -0400
Received: by bke11 with SMTP id 11so444536bke.19
        for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 10:29:33 -0700 (PDT)
In-Reply-To: <4E40F53A.2080303@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 9, 2011 at 4:52 AM, Benny Halevy <bhalevy@tonian.com> wrote=
:
> On 2011-08-08 15:01, Olga Kornievskaia wrote:
>> I'd like to 2nd this.
>>
>> Current pnfs server doesn't build if chosen to be build into the
>> kernel. It does build, if built as a module.
>>
>> when client and server code is build into the kernel it seems that
>> both sides try to define pnfs_roc() function and stepping on each
>> others toes..
>>
>> On Fri, Aug 5, 2011 at 9:58 PM, Billy Hass <billdh16@gmail.com> wrot=
e:
>>> Hey all,
>>>
>>> I am unable to compile the latest kernel from the git tree.
>>>
>>> git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
>>> cd linux-pnfs
>>> make oldconfig
>>> make -j5 -s
>>> =A0 =A0 =A0[ ... ]
>>> =A0 =A0 =A0[A lot of warnings, but no errors]
>>> =A0 =A0 =A0[ ... ]
>>> make install
>>> =A0 =A0 =A0sh /usr/src/kernels/3.0.0/linux-
>>> =A0 =A0 pnfs/arch/x86/boot/install.sh 3.0.0-pnfs arch/x86/boot/bzIm=
age \
>>> =A0 =A0 =A0 =A0 =A0System.map "/boot"
>>> =A0 =A0 =A0 *** Missing file: arch/x86/boot/bzImage
>>> =A0 =A0 =A0 *** You need to run "make" before "make install".
>>> =A0 =A0 =A0make[1]: *** [install] Error 1
>>> =A0 =A0 =A0make: *** [install] Error 2
>>>
>>> When I try to do the make again, here is the output
>>> make -j5 -s
>>> =A0 =A0 =A0fs/nfsd/built-in.o: In function `pnfs_roc':
>>> =A0 =A0 =A0(.text+0x226d1): multiple definition of `pnfs_roc'
>>> =A0 =A0 =A0fs/nfs/built-in.o:(.text+0x304ee): first defined here
>>> =A0 =A0 =A0make[1]: *** [fs/built-in.o] Error 1
>>> =A0 =A0 =A0make: *** [fs] Error 2
>>> =A0 =A0 =A0make: *** Waiting for unfinished jobs....
>>>
>>> Thanks for any help!
>>>
>>> Bill
>>>
>>> --
>>> Bill D. Hass
>>> Major | Electrical Engineering BSE
>>> Minor | Mathematics
>>> University of Michigan '13
>>> College of Engineering
>>> (715) 923-8382
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
> Right. =A0The following patch simply renames the function for pnfsd.
> I'm pushing it to pnfs-all-3.0 and I'll add it to the 3.1-rc tree
> (pnfs-all-latest) once I finish rebasing and testing it.
>
> Benny
>
> From d76f73eca38fd7b803d80e78cfa8f9468e83a9b3 Mon Sep 17 00:00:00 200=
1
> From: Benny Halevy <benny@tonian.com>
> Date: Tue, 9 Aug 2011 01:11:16 -0400
> Subject: [PATCH] SQUASHME: pnfsd: rename pnfs_roc to pnfsd_roc
>
> It clashes with a function called the same in the nfs module
>
> Signed-off-by: Benny Halevy <benny@tonian.com>
> ---
> =A0fs/nfsd/nfs4pnfsd.c | =A0 =A02 +-
> =A0fs/nfsd/nfs4state.c | =A0 =A02 +-
> =A0fs/nfsd/pnfsd.h =A0 =A0 | =A0 =A02 +-
> =A03 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index b1f67eb..e0669ad 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -1336,7 +1336,7 @@ nomatching_layout(struct nfs4_layoutrecall *clr=
)
> =A0* =A0 the layout and simulate a layout_return. Surly the client ha=
s forgotten
> =A0* =A0 these layouts or it would return them before the close.
> =A0*/
> -void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp)
> +void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
> =A0{
> =A0 =A0 =A0 =A0struct nfs4_layout *lo, *nextlp;
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1941051..b95589e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3620,7 +3620,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd=
4_compound_state *cstate,
> =A0 =A0 =A0 =A0update_stateid(&stp->st_stateid);
> =A0 =A0 =A0 =A0memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(st=
ateid_t));
>
> - =A0 =A0 =A0 pnfs_roc(stp->st_stateowner->so_client, stp->st_file);
> + =A0 =A0 =A0 pnfsd_roc(stp->st_stateowner->so_client, stp->st_file);
>
> =A0 =A0 =A0 =A0/* release_stateid() calls nfsd_close() if needed */
> =A0 =A0 =A0 =A0release_open_stateid(stp);
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index a4c8a9c..6e60d2c 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -125,7 +125,7 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_sta=
te *);
> =A0void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *=
);
> =A0int put_layoutrecall(struct nfs4_layoutrecall *);
> =A0void nomatching_layout(struct nfs4_layoutrecall *);
> -void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp);
> +void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
> =A0void *layoutrecall_done(struct nfs4_layoutrecall *);
> =A0void nfsd4_cb_layout(struct nfs4_layoutrecall *);
> =A0int _nfsd_layout_recall_cb(struct super_block *, struct inode *,
> --
> 1.7.6
>
>

I updated to the latest git today and I am still having trouble compili=
ng.

[root@pdsi8 linux-pnfs]# make -j5 -s
[...]
drivers/isdn/hardware/mISDN/hfcpci.c:2319:2: warning: ignoring return
value of =91driver_for_each_device=92, declared with attribute
warn_unused_result [-Wunused-result]
drivers/isdn/hardware/eicon/message.c: In function =91mixer_notify_upda=
te=92:
drivers/isdn/hardware/eicon/message.c:11308:54: warning: array
subscript is above array bounds [-Warray-bounds]
fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors
make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
make[1]: *** [fs/xfs] Error 2
make: *** [fs] Error 2
make: *** Waiting for unfinished jobs....
In file included from drivers/message/i2o/config-osm.c:39:0:
drivers/message/i2o/i2o_config.c: In function =91i2o_cfg_passthru=92:
[...]

[root@pdsi8 linux-pnfs]# make modules && make modules_install && make i=
nstall
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC [M]  fs/xfs/linux-2.6/xfs_iops.o
fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors
make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
make[1]: *** [fs/xfs] Error 2
make: *** [fs] Error 2

Here is my second make after a failed make:
[root@pdsi8 linux-pnfs]# make -j5 -s
fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors
make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
make[1]: *** [fs/xfs] Error 2
make: *** [fs] Error 2
make: *** Waiting for unfinished jobs....


--=20
Bill D. Hass
Major | Electrical Engineering BSE
Minor | Mathematics
University of Michigan '13
College of Engineering
(715) 923-8382
