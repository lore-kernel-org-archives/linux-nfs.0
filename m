Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.math.uh.edu ([129.7.128.33]:46417 "EHLO mx2.math.uh.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbbDBTEv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 15:04:51 -0400
Received: from epithumia.math.uh.edu ([129.7.128.2])
	by mx2.math.uh.edu with esmtp (Exim 4.84)
	(envelope-from <tibbs@math.uh.edu>)
	id 1YdjNs-0001R1-5y
	for linux-nfs@vger.kernel.org; Thu, 02 Apr 2015 12:58:28 -0500
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: linux-nfs@vger.kernel.org
Subject: All access to NFS4 krb5p server hanging when one user has an expired ticket
Date: Thu, 02 Apr 2015 12:58:28 -0500
Message-ID: <ufamw2qfm4b.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm running into an odd issue that I haven't been able to figure out.  I
have four identical NFS servers running the current Centos 7 release and
currently have their 3.10.0-123.20.1.el7.x86_64 kernel booted.  (Yeah, I
know, Centos/EL have outdated kernel bits, but I don't have anough info
to make a good bug report at this point.)  My clients are all Fedora 21
running 3.19.1.

Two of the servers have a single filesystem exported with either
sec=krb5p:krb5i:krb5 or sec=krb5p:krb5i:krb5:sys.  This filesystem has
no data and is not accessed by clients.  The other filesystems are
exported without any sec= option.

After a while, client access to all filesystems on one of the servers
will begin to hang uninterruptibly; the following appears repeatedly,
once a second, in the kernel log:

NFS: state manager: check lease failed on NFSv4 server nas01 with error 13

There are no problems accessing filesystems on the other servers during
this time.

If I kill all user processes that have any filesystems from that one
server and umount all of the relevant filesystems, things start working
and fresh mounts from that server can be accessed.  However, things
begin failing again after what appears to be very close to 24 hours.
That happens to be the default kerberos ticket expiration time.  (I did
not have sssd auto ticket renewal enabled on the client.)

I think this is quite similar to what was reported here several years
ago in
   http://www.spinics.net/lists/linux-nfs/msg22430.html
except that it appears to be even worse; even if users aren't using the
kerberized filesystem and the filesystems are all mounted sec=sys,
things still eventually hang for everyone when a ticket expires.  I am
assuming that a kerberos ticket exchange still happens because the
server has one kerberized export, even if the requested filesystem isn't
kerberized.  But that's all really just conjecture.

Some relevant software versions:

Server:
kernel-3.10.0-123.20.1.el7.x86_64
nfs-utils-1.3.0-0.8.el7.x86_64
gssproxy-0.3.0-10.el7.x86_64
krb5-libs-1.12.2-14.el7.x86_64

Client:
kernel-3.19.1-201.fc21.x86_64
nfs-utils-1.3.1-6.2.fc21.x86_64
gssproxy-0.3.1-4.fc21.x86_64
krb5-libs-1.12.2-14.fc21.x86_64

And just in case, the KDC:
krb5-server-1.12.2-14.fc21.x86_64
krb5-libs-1.12.2-14.fc21.x86_64

 - J<
