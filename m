Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ax13.adsl.tnnet.fi ([217.112.254.13]:49517 "EHLO
	mail.opinsys.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752825Ab1GGOPT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:15:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.opinsys.fi (Postfix) with ESMTP id 0DCBF208D69
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jul 2011 17:05:44 +0300 (EEST)
Received: from mail.opinsys.fi ([127.0.0.1])
	by localhost (mail.opinsys.fi [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nuPzWolsBejC for <linux-nfs@vger.kernel.org>;
	Thu,  7 Jul 2011 17:05:37 +0300 (EEST)
Received: from mail.opinsys.fi (mail.opinsys.fi [10.246.133.21])
	by mail.opinsys.fi (Postfix) with ESMTP id 3ACEF208D72
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jul 2011 17:05:37 +0300 (EEST)
Date: Thu, 07 Jul 2011 14:05:37 -0000 (UTC)
From: Juha =?utf-8?Q?Erkkil=C3=A4?= <juha.erkkila@opinsys.fi>
To: linux-nfs@vger.kernel.org
Subject: state manager failed on NFSv4 server nfsserver.kehitys.opinsys.fi with error 13
Message-ID: <08967499-6b9d-4dbb-8118-5e6e1e3ef06f@mail>
In-Reply-To: <01afeb43-9245-489a-9110-56706aadecbf@mail>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello.

I am encountering an issue with NFSv4 with sec=krb5 mount option.
Processes that hold files open on an NFS-mount, while their users'
kerberos tickets are removed from under /tmp, may block other users from
accessing files on the same NFS-mount.

Kernel is version 2.6.39.2 from http://kernel.org, compiled for:

Distributor ID: Ubuntu
Description:    Ubuntu 10.04.2 LTS
Release:        10.04
Codename:       lucid

I have updated some relevant packages from more recent Ubuntu versions
compiled for 10.04:

ii  module-init-tools   3.16-1ubuntu1     tools for managing Linux kernel modules
ii  nfs-common          1:1.2.2-4ubuntu7  NFS support files common to client and server
ii  nfs-kernel-server   1:1.2.2-4ubuntu7  support for NFS kernel server
ii  portmap             6.0.0-2ubuntu5    RPC port mapper

This issue was first encountered and can be reproduced with Ubuntu
10.04.2 using Linux kernel 2.6.32-32.62 (Ubuntu package 2.6.32-32-server).
It seems that the bug is at least almost four years old.  Here are some
bug reports that appear to be on the same issue:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/409438
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=446238
http://comments.gmane.org/gmane.linux.nfsv4/10681
https://bugzilla.novell.com/show_bug.cgi?id=620066#c8

Here are some bug reports that have similar symptoms, but look slightly
different and are possibly or likely triggered by different bugs:

https://bugzilla.kernel.org/show_bug.cgi?id=15973
http://www.spinics.net/lists/linux-nfs/msg16304.html
http://linux-nfs.org/pipermail/nfsv4/2010-February/012251.html
https://bugs.launchpad.net/ubuntu/+bug/794112

Here are some instructions that should be enough to reproduce the bug.

Configure NFSv4, one machine acting as a server and one as a client.
I use the following /etc/exports on the server:

-----
/export                 gss/krb5(rw,fsid=0,async,subtree_check,no_root_squash,crossmnt)
/export/home            gss/krb5(rw,async,subtree_check,no_root_squash)
/export/home/kehitys    gss/krb5(rw,async,subtree_check,root_squash,crossmnt)
-----

On the server side, also make sure that nfs4leasetime is not very long
(very long meaning much more than 90 seconds).  At one point in this
test the NFSv4 lease time should expire (I am not 100% sure about this,
but nevertheless it seems that shorter times are more prone to trigger
the problem), so check this value:

root@nfsserver:~$ cat /proc/fs/nfsd/nfsv4leasetime
90

On the client side mount the exported directory with:

root@nfsclient:~$ mount -t nfs4 -o rw,sec=krb5 nfsserver:/home/kehitys \
                        /home/kehitys

Do also run the rpc.gssd daemon with "-t 60" option on the client side:

root@nfsclient$ rpc.gssd -rrr -vvv -t 60

Using "-t 60" makes the bug a lot easier to reproduce, and may
be necessary to trigger the bug with the 2.6.39.2 kernel.  On the
2.6.32-32.62 kernel, however, this is not necessary, but without the
"-t 60" option one needs to wait a whole lot longer to trigger the issue
(perhaps half an hour or more, see below).

This bug is reproduceable when there are valid kerberos tickets under
/tmp, but for most tests I have removed all user kerberos tickets
from /tmp before trying this, so I suggest you do the same.

Login to the NFS client as some user that has kerberos credentials.
Make sure user has a kerberos ticket under /tmp (execute klist, perhaps,
to see the contents of ticket cache file).  Open some file in the NFS
mount for reading, but do not actually read from it (doing the same in
write-mode will probably also work):

mr.problem@nfsclient$ echo "hello nfs server" > somefile
mr.problem@nfsclient$ sleep 100000 < somefile &
mr.problem@nfsclient$ kdestroy

Now the kerberos ticket is removed from under /tmp (note that no kerberos
tickets need to expire during this test).  Now wait.  After about one
minute you should start seeing the following message from the kernel:

Jul  5 12:35:56 nfsclient kernel: [  322.130939] Error: state manager failed on NFSv4 server nfsserver.kehitys.opinsys.fi with error 13

In case the "-t 60" option was not used for rpc.gssd, instead of waiting
about one minute you may have to wait for half an hour or more (this may
not be reproducible in 2.6.39.2).  IIRC, 2.6.32 also did not output the
error message above.

Now, wait for two minutes (I suppose that the NFS lease needs to expire
at this stage).  Then try to log in as another user and access the NFS
mount by reading or writing to it.  Now the kernel starts complaining
repeatedly the "state manager failed" error, perhaps ~300 times a second.
Also rpc.gssd starting consuming excessive amounts of CPU time, iterating
through tickets under /tmp.

Other NFS mounts on the client may also be disturbed in this situation,
but this may not be if they reside on different exports on the server.

This situation resolves itself if the user that has the processes holding
files open on the NFS-mount (without a ticket) gets a fresh ticket (try it
with kinit).  It also partially resolves itself if other users try to log
in, in that NFS may work for them properly, but the underlying cause still
exists and the "state manager failed" error does not completely disappear.

A possibly related point: rpc.gssd(8) manual page states that there is
no explicit timeout for kernel gss contexts:

        The default is no explicit timeout, which means the kernel
        context will live the lifetime of the Kerberos service ticket
        used in its creation.

However, my tests indicate that if a process is writing to an NFS 
mount and the kerberos ticket for its user is removed, the process may 
write to the file perhaps about 11 minutes before it gets "permission
denied"-message (this was with 2.6.32-32.62).  This would suggest that
kernel gss contexts do indeed expire before the tickets expire, but I
have not verified this directly.  This would explain why the "-t 60" 
option for rpc.gssd is not necessary to trigger this bug.  However, this
"permission denied" will not occur if process is only holding files open
and not acting on them.

On the kernel level, the problematic code is somewhere around
fs/nfs/nfs4state.c in function nfs4_state_manager(), as it checks lease
by calling nfs4_check_lease().  This calls

  cred = ops->get_state_renewal_cred_locked(clp)

This function is set in fs/nfs/nfs4proc.c.  In NFSv4.0 it points
to nfs4_get_renew_cred_locked(), whereas in NFSv4.1 it points to
nfs4_get_machine_cred_locked().  Thus, in NFSv4.0 a list of (apparently
user?) credentials are used for renewing the lease, whereis in NFSv4.1 the
machine credentials are used exclusively?

I wonder what is the reason for this change?  It looks as if the
nfs4_get_renew_cred_locked() function may return some bad credential,
because lease renewal does not succeed.  nfs4_check_lease() returns 
NFS4ERR_ACCESS (13) error code, nfs4_recovery_handle_error() does not
handle this, and the kernel and rpc.gssd start their dance, both of
them complaining.

Juha
