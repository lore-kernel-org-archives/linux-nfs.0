Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26671 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967024AbdKRRTy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 12:19:54 -0500
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Anna.Schumaker@Netapp.com, trond.myklebust@primarydata.com
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Commit fcd8843c40 breaks old compilers
Message-ID: <09a3d9ca-d191-5899-613d-8d0dbe0b68ea@oracle.com>
Date: Sat, 18 Nov 2017 12:19:43 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fcd8843c406b46433857ae45e5e9d84b01a7d20b breaks on older
compilers which cannot process initializers for anonymous structures:

+const nfs4_stateid invalid_stateid = {
+       {
+               .seqid = cpu_to_be32(0xffffffffU),
+               .other = { 0 },
+       },
+       .type = NFS4_INVALID_STATEID_TYPE,
+};


/home/build/linux-linus/fs/nfs/nfs4state.c:74: error: unknown field
‘seqid’ specified in initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: missing braces
around initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: (near
initialization for ‘invalid_stateid.<anonymous>.data’)
/home/build/linux-linus/fs/nfs/nfs4state.c:74: warning: overflow in
implicit constant conversion
/home/build/linux-linus/fs/nfs/nfs4state.c:75: error: unknown field
‘other’ specified in initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:75: error: extra brace group
at end of initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:75: error: (near
initialization for ‘invalid_stateid.<anonymous>’)
/home/build/linux-linus/fs/nfs/nfs4state.c:75: warning: excess elements
in union initializer
/home/build/linux-linus/fs/nfs/nfs4state.c:75: warning: (near
initialization for ‘invalid_stateid.<anonymous>’)
make[4]: *** [fs/nfs/nfs4state.o] Error 1
make[3]: *** [fs/nfs] Error 2


FC-64 <build@build-mk2:~> gcc --version
gcc (GCC) 4.4.4 20100503 (Red Hat 4.4.4-2)


A similar bug was fixed by e0714ec4f9efe7b86828b0dcc077fd8f5d8e5e91 but
I don't think the same approach can work here.


-boris
