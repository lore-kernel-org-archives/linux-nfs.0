From: Eric Veith1 <eric.veith-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Using xdr_string(..) causes segmentation fault
Date: Tue, 9 Mar 2010 18:31:20 +0100
Message-ID: <OF9AF9E11F.A0757E1F-ONC12576E1.005FC262-C12576E1.00604111@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:33846 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0CIRbX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 12:31:23 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o29HVLY7019440
	for <linux-nfs@vger.kernel.org>; Tue, 9 Mar 2010 17:31:21 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o29HVM6f1577200
	for <linux-nfs@vger.kernel.org>; Tue, 9 Mar 2010 18:31:22 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o29HVMAl002214
	for <linux-nfs@vger.kernel.org>; Tue, 9 Mar 2010 18:31:22 +0100
Received: from d12ml072.megacenter.de.ibm.com (d12ml072.megacenter.de.ibm.com [9.149.166.115])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id o29HVMeX002211
	for <linux-nfs@vger.kernel.org>; Tue, 9 Mar 2010 18:31:22 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list,

this post is not strictly NFS but RPC related; I post it here for a lac=
k=20
of knowing about a better place. If it was totally wrong to post it her=
e,=20
would somebody please point me to a better place? Thanks!

I'm trying to do some very basic RPC calls both for testing stuff and o=
ut=20
of interest. I'd like to, in this example, issue a RPC mount call.=20
However, I'm getting a segmentation fault which I traced back to=20
xdr_string of <rpc/rpc.h>:

---%<---
char *mountpoint;
asprintf(&mountpoint, "%s\0", argv[2]);

mountres3 *mnt3res =3D malloc(sizeof(mountres3));
struct timeval timeout =3D {
    .tv_sec =3D 60,
    .tv_usec =3D 0
};
enum clnt_stat stat =3D clnt_call(mount_clnt, MOUNTPROC3_MNT,=20
        (xdrproc_t) xdr_dirpath, (caddr_t) mountpoint,
        (xdrproc_t) xdr_mountres3, (caddr_t) mnt3res,=20
        timeout);
--->%---

I've used the mount.x file with rpcgen to get xdr_dirpath and the likes=
=2E=20

Could somebody please point out the mistake I'm obviously doing here?

Thanks alot in advance,
                Eric

--
Eric MSP Veith <eric.veith-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Hechtsheimer Str. 2
DE-55131 Mainz
Germany

IBM Deutschland GmbH
Vorsitzender des Aufsichtsrats: Erich Clementi
Gesch=E4ftsf=FChrung: Martin Jetter (Vorsitzender), Reinhard Reschke,=20
Christoph Grandpierre, Matthias Hartmann, Michael Diemer, Martina=20
Koederitz
Sitz der Gesellschaft: Stuttgart
Registergericht: Amtsgericht Stuttgart, HRB 14562
WEEE-Reg.-Nr. DE 99369940
