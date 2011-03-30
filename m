Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755795Ab1C3Tcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2011 15:32:43 -0400
Subject: [REGRESSION] 8f70e95f9f4159184f557 causes mount failure with EGAIN
From: Eric Paris <eparis@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: bjschuma@netapp.com, Trond.Myklebust@netapp.com
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 15:32:41 -0400
Message-ID: <1301513561.561.7.camel@unknown001a4b0c2895>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

$ git bisect good
8f70e95f9f4159184f557a1db60c909d7c1bd2e3 is the first bad commit
commit 8f70e95f9f4159184f557a1db60c909d7c1bd2e3
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Mar 24 17:12:31 2011 +0000

    NFS: Determine initial mount security
    
    When sec=<something> is not presented as a mount option,
    we should attempt to determine what security flavor the
    server is using.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Using a linux-next kernel for the last 2 days I have been unable to
mount exports from my RHEL6 server.  mount(2) returned EAGAIN.  Turned
up debugging (thanks jlayton) and got:

        [ 1732.795056] NFS: nfs mount opts='tcp,vers=4,addr=10.11.231.241,clientaddr=10.11.231.191'
        [ 1732.798079] NFS:   parsing nfs mount option 'tcp'
        [ 1732.800210] NFS:   parsing nfs mount option 'vers=4'
        [ 1732.802324] NFS:   parsing nfs mount option 'addr=10.11.231.241'
        [ 1732.804477] NFS:   parsing nfs mount option 'clientaddr=10.11.231.191'
        [ 1732.805790] NFS: MNTPATH: '/export/'
        [ 1732.806663] --> nfs4_try_mount()
        [ 1732.807459] --> nfs4_create_server()
        [ 1732.808301] --> nfs4_init_server()
        [ 1732.809136] --> nfs4_set_client()
        [ 1732.809898] --> nfs_get_client(paris.rdu.redhat.com,v4)
        [ 1732.811122] NFS: get client cookie (0xffff880039cfd9e8/0xffff88003b889000)
        [ 1732.813771] NFS: Callback listener port = 36700 (af 2)
        [ 1732.814931] NFS: Callback listener port = 60202 (af 10)
        [ 1732.816199] --> nfs_get_client() = ffff880039cfd9e8 [new]
        [ 1732.817356] <-- nfs4_set_client() = 0 [new ffff880039cfd9e8]
        [ 1732.818587] <-- nfs4_init_server() = 0
        [ 1732.819476] --> nfs4_get_rootfh()
        [ 1732.820282] encode_compound: tag=
        [ 1732.822070] encode_compound: tag=
        [ 1732.822937] nfs4_get_rootfh: getroot error = 11
        [ 1732.823982] <-- nfs4_get_rootfh() = -11
        [ 1732.824880] --> nfs_free_server()
        [ 1732.846219] --> nfs_put_client({1})
        [ 1732.847888] --> nfs_free_client(4)
        [ 1732.850236] NFS: releasing client cookie (0xffff880039cfd9e8/0xffff88003b889000)
        [ 1732.853726] <-- nfs_free_client()
        [ 1732.854505] <-- nfs_free_server()
        [ 1732.855274] <-- nfs4_create_server() = error -11
        [ 1732.856187] <-- nfs4_try_mount() = -11 [error]

Bisected and got the commit listed above.

