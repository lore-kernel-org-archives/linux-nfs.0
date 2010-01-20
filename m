From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/7] nfs41: implement cb_recall_slot
Date: Wed, 20 Jan 2010 15:38:44 -0500
Message-ID: <1264019924.7799.0.camel@localhost>
References: <1263509110-3097-1-git-send-email-andros@netapp.com>
	 <1263509110-3097-2-git-send-email-andros@netapp.com>
	 <1263509110-3097-3-git-send-email-andros@netapp.com>
	 <1263509110-3097-4-git-send-email-andros@netapp.com>
	 <1263509110-3097-5-git-send-email-andros@netapp.com>
	 <1263509110-3097-6-git-send-email-andros@netapp.com>
	 <1263509110-3097-7-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711Ab0ATUjP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 15:39:15 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0KKcm9l009061
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jan 2010 12:38:49 -0800 (PST)
In-Reply-To: <1263509110-3097-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-14 at 17:45 -0500, andros@netapp.com wrote:=20
> From: Andy Adamson <andros@netapp.com>
>=20
> Drain the fore channel and reset the max_slots to the new value.
>=20
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback.h         |    8 ++++++++
>  fs/nfs/callback_proc.c    |   32 ++++++++++++++++++++++++++++++++
>  fs/nfs/callback_xdr.c     |   22 +++++++++++++++++++++-
>  fs/nfs/nfs4_fs.h          |    2 ++
>  fs/nfs/nfs4state.c        |   43 +++++++++++++++++++++++++++++++++++=
++++++++
>  include/linux/nfs_fs_sb.h |    2 ++
>  6 files changed, 108 insertions(+), 1 deletions(-)

  CC [M]  fs/nfs/nfs4state.o
/home/trondmy/devel/linux/linux_nfs-2.6/fs/nfs/nfs4state.c: In function
=E2=80=98nfs4_state_manager=E2=80=99:
/home/trondmy/devel/linux/linux_nfs-2.6/fs/nfs/nfs4state.c:1437: error:
implicit declaration of function =E2=80=98nfs4_recall_slot=E2=80=99
make[2]: *** [fs/nfs/nfs4state.o] Error 1
make[1]: *** [fs/nfs/nfs4state.o] Error 2
make: *** [sub-make] Error 2

Does not compile without CONFIG_NFS_V4_1

Trond
