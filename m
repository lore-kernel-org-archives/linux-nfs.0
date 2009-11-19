From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client bugfixes
Date: Thu, 19 Nov 2009 11:35:08 -0500
Message-ID: <1258648508.30333.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbZKSQgM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Nov 2009 11:36:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfix=
es

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4proc.c |    2 +-
 net/sunrpc/addr.c |   18 ++++++++----------
 2 files changed, 9 insertions(+), 11 deletions(-)

commit 1e360a60b24ad8f8685af66fa6de10ce46693a4b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Nov 13 10:52:55 2009 -0500

    SUNRPC: Address buffer overrun in rpc_uaddr2sockaddr()
   =20
    The size of buf[] must account for the string termination needed fo=
r
    the first strict_strtoul() call.  Introduced in commit a02d6926.
   =20
    F=C3=A1bio Oliv=C3=A9 Leite points out that strict_strtoul() requir=
es _either_
    '\n\0' _or_ '\0' termination, so use the simpler '\0' here instead.
   =20
    See http://bugzilla.kernel.org/show_bug.cgi?id=3D14546 .
   =20
    Reported-by: argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: F=C3=A1bio Oliv=C3=A9 Leite <fleite@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 96d25e532234bec1a1989e6e1baf702d43a78b0d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Nov 11 16:15:42 2009 +0900

    NFSv4: Fix a cache validation bug which causes getcwd() to return E=
NOENT
   =20
    Changeset a65318bf3afc93ce49227e849d213799b072c5fd (NFSv4: Simplify=
 some
    cache consistency post-op GETATTRs) incorrectly changed the getattr
    bitmap for readdir().
    This causes the readdir() function to fail to return a
    fileid/inode number, which again exposed a bug in the NFS readdir c=
ode that
    causes spurious ENOENT errors to appear in applications (see
    http://bugzilla.kernel.org/show_bug.cgi?id=3D14541).
   =20
    The immediate band aid is to revert the incorrect bitmap change, bu=
t more
    long term, we should change the NFS readdir code to cope with the
    fact that NFSv4 servers are not required to support fileids/inode n=
umbers.
   =20
    Reported-by: Daniel J Blueman <daniel.blueman@gmail.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


