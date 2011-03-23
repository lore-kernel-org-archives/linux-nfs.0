Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756647Ab1CWTeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 15:34:07 -0400
Date: Wed, 23 Mar 2011 15:34:06 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 2.6.39
Message-ID: <20110323193406.GB26306@fieldses.org>
Content-Type: text/plain; charset=utf-8
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following nfsd changes are available from the for-2.6.39 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.39

This was a quiet release cycle!  Kevin Coffman added a new interface
allowing userland to query our enctype support, fixing some problems
with rpcsec_gss security negotiation; other than that, these are routine
bugfixes.

I do have one more set of server rpc patches that I may pass along in a
few days depending on some test results.

--b.

J. Bruce Fields (7):
      svcrpc: fix rare race on unix_domain creation
      nfsd4: minor nfs4state.c reshuffling
      nfsd4: fix struct file leak
      svcrpc: fix bad argument in unix_domain_find
      nfsd: fix compile error
      nfsd4: fix comment and remove unused nfsd4_file fields
      Merge create_session decoding fix into for-2.6.39

Jesper Juhl (2):
      NFSD, VFS: Remove dead code in nfsd_rename()
      SUNRPC: Remove resource leak in svc_rdma_send_error()

Kevin Coffman (2):
      gss:krb5 only include enctype numbers in gm_upcall_enctypes
      nfsd: add proc file listing kernel's gss_krb5 enctypes

Mi Jinlong (3):
      nfsd41: modify the members value of nfsd4_op_flags
      nfs41: make sure nfs server return right ca_maxresponsesize_cached
      nfsd: wrong index used in inner loop

Namhyung Kim (1):
      locks: use assign_type()

Shan Wei (1):
      nfsd: kill unused macro definition

commit 4be34b9d69c97211ff4eb00d79078f3c1593804d
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Sat Jan 22 22:40:20 2011 +0100

    SUNRPC: Remove resource leak in svc_rdma_send_error()
    
    We leak the memory allocated to 'ctxt' when we return after
    'ib_dma_mapping_error()' returns !=0.
    
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 5a02ab7c3c4580f94d13c683721039855b67cda6
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Fri Mar 11 12:13:55 2011 +0800

    nfsd: wrong index used in inner loop
    
    We must not use dummy for index.
    After the first index, READ32(dummy) will change dummy!!!!
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    [bfields@redhat.com: Trond points out READ_BUF alone is sufficient.]
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit cf507b6f8ebae89c0e7bbd00abc6d8887c9035b1
Merge: 9ae78bc 3ec07aa
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 17 13:07:20 2011 -0400

    Merge create_session decoding fix into for-2.6.39
    
    This needs a further fixup!

commit 9ae78bcc000168251f893b1bf92a848308187695
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 17 12:52:33 2011 -0400

    nfsd4: fix comment and remove unused nfsd4_file fields
    
    A couple fields here were left over from a previous version of a patch,
    and are no longer used.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit d2b217439fd1d8f7857175f063113f4d1d66306c
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Thu Mar 10 17:43:37 2011 +0800

    nfs41: make sure nfs server return right ca_maxresponsesize_cached
    
    According to rfc5661,
    
      ca_maxresponsesize_cached:
    
         Like ca_maxresponsesize, but the maximum size of a reply that
         will be stored in the reply cache (Section 2.10.6.1).  For each
         channel, the server MAY decrease this value, but MUST NOT
         increase it.
    
    the latest kernel(2.6.38-rc8) may increase the value for ignoring
    request's ca_maxresponsesize_cached value. We should not ignore it.
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 0a5e5f122c756d1c1a6ca712eda76ea8664e5fd9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Mar 14 20:57:44 2011 -0400

    nfsd: fix compile error
    
    "fs/built-in.o: In function `supported_enctypes_show':
    nfsctl.c:(.text+0x7beb0): undefined reference to `gss_mech_get_by_name'
    nfsctl.c:(.text+0x7bebc): undefined reference to `gss_mech_put'
    "
    
    Reported-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 352b5d13c0684ba8cd103aa20cb74f105334562a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Mar 9 22:40:30 2011 -0500

    svcrpc: fix bad argument in unix_domain_find
    
    "After merging the nfsd tree, today's linux-next build (powerpc
    ppc64_defconfig) produced this warning:
    
    net/sunrpc/svcauth_unix.c: In function 'unix_domain_find':
    net/sunrpc/svcauth_unix.c:58: warning: passing argument 1 of
    +'svcauth_unix_domain_release' from incompatible pointer type
    net/sunrpc/svcauth_unix.c:41: note: expected 'struct auth_domain *' but
    argument
    +is of type 'struct unix_domain *'
    
    Introduced by commit 8b3e07ac908d ("svcrpc: fix rare race on unix_domain
    creation")."
    
    Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 0997b173609b9229ece28941c118a2a9b278796e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Mar 2 18:01:35 2011 -0500

    nfsd4: fix struct file leak
    
    Make sure we properly reference count the struct files that a lock
    depends on, and release them when the lock stateid is released.
    
    This fixes a major leak of struct files when using locking over nfsv4.
    
    Cc: stable@kernel.org
    Reported-by: Rick Koshi <nfs-bug-report@more-right-rudder.com>
    Tested-by: Ivo Přikryl <prikryl@eurosat.cz>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 529d7b2a7fa31e9f7d08bc790d232c3cbe64fa24
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Mar 2 23:48:33 2011 -0500

    nfsd4: minor nfs4state.c reshuffling
    
    Minor cleanup in preparation for a bugfix--moving some code to avoid
    forward references, etc.  No change in functionality.
    
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 8b3e07ac908d005bb791410f594cce8744f6806a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Mar 7 22:50:47 2011 -0500

    svcrpc: fix rare race on unix_domain creation
    
    Note that "new" here is not yet fully initialized; auth_domain_put
    should be called only on auth_domains that have actually been added to
    the hash.
    
    Before this fix, two attempts to add the same domain at once could
    cause the hlist_del in auth_domain_put to fail.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 5ece3cafbd88d4da5c734e1810c4a2e6474b57b2
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Fri Feb 18 09:08:31 2011 +0800

    nfsd41: modify the members value of nfsd4_op_flags
    
    The members of nfsd4_op_flags, (ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS)
    equals to  ALLOWED_AS_FIRST_OP, maybe that's not what we want.
    
    OP_PUTROOTFH with op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
    can't appears as the first operation with out SEQUENCE ops.
    
    This patch modify the wrong value of ALLOWED_WITHOUT_FH etc which
    was introduced by f9bb94c4.
    
    Cc: stable@kernel.org
    Reviewed-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit b0b0c0a26e846ae6646af9f59a3d2ea06b49cbc7
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 2 19:51:42 2011 -0500

    nfsd: add proc file listing kernel's gss_krb5 enctypes
    
    Add a new proc file which lists the encryption types supported
    by the kernel's gss_krb5 code.
    
    Newer MIT Kerberos libraries support the assertion of acceptor
    subkeys.  This enctype information allows user-land (svcgssd)
    to request that the Kerberos libraries limit the encryption
    types that it uses when generating the subkeys.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 540c8cb6a576f34a9a0b04467f46bb6e67a1f852
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed Mar 2 19:51:41 2011 -0500

    gss:krb5 only include enctype numbers in gm_upcall_enctypes
    
    Make the value in gm_upcall_enctypes just the enctype values.
    This allows the values to be used more easily elsewhere.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 46d4cef9cf54f2f8b15216e3f6dad69750c69e0c
Author: Jesper Juhl <jj@chaosbits.net>
Date:   Sun Mar 6 00:30:35 2011 +0100

    NFSD, VFS: Remove dead code in nfsd_rename()
    
    Currently we have the following code in fs/nfsd/vfs.c::nfsd_rename() :
    
    	...
    	host_err = nfsd_break_lease(odentry->d_inode);
    	if (host_err)
    		goto out_drop_write;
    	if (ndentry->d_inode) {
    		host_err = nfsd_break_lease(ndentry->d_inode);
    		if (host_err)
    			goto out_drop_write;
    	}
    	if (host_err)
    		goto out_drop_write;
    	...
    
    'host_err' is guaranteed to be 0 by the time we test 'ndentry->d_inode'.
    If 'host_err' becomes != 0 inside the 'if' statement, then we goto
    'out_drop_write'. So, after the 'if' statement there is no way that
    'host_err' can be anything but 0, so the test afterwards is just dead
    code.
    This patch removes the dead code.
    
    Signed-off-by: Jesper Juhl <jj@chaosbits.net>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 35079582e72efcabf7c70f3d3ee4f96e6f196606
Author: Shan Wei <shanwei@cn.fujitsu.com>
Date:   Fri Jan 14 17:35:59 2011 +0800

    nfsd: kill unused macro definition
    
    These macros had never been used for several years.
    So, remove them.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit f32cb53219a956b96a4cd1ee7c6b1b8a48d40e9f
Author: Namhyung Kim <namhyung@gmail.com>
Date:   Mon Jan 17 15:45:59 2011 +0900

    locks: use assign_type()
    
    Signed-off-by: Namhyung Kim <namhyung@gmail.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
