Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50749 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903Ab3EIRBV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 13:01:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        "Hin-Tak Leung" <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Date: Thu, 9 May 2013 17:01:18 +0000
Message-ID: <1368118877.3282.104.camel@leira.trondhjem.org>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
In-Reply-To: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-09 at 20:37 +0400, Vyacheslav Dubeyko wrote:
> Hi,
> 
> This patchset implements ACLs support in hfsplus driver and generalizes NFSv4 ACLs <-> POSIX ACLs mapping algorithms.
> 
> v3->v4
> * Introduce interface of NFSv4 ACLs <-> POSIX ACLs mapping (J. Bruce Fields request).
> * Introduce generalization of NFSv4 ACLs <-> POSIX ACLs mapping algorithms (J. Bruce Fields request).
> * Rework ACLs support in HFS+ driver with the purpose of using generalized mapping algorithms.
> * Change dprint() on hfs_dbg() calls.
> * Enhance debug output in fs/hfsplus/acl.c.
> 
> v2->v3
> * Fix errors in dprint_hexdump() macro.
> * Correct format on %zd for size_t in dprint() calls.
> 
> v1->v2
> * Add several dprint() messages.
> * Change hardcoded function names on __func__ macro.
> * Fix coding style errors.
> 
> The include/linux/nfs4acl.h header file is created with the purpose of sharing declarations and structures that were moved from fs/nfsd/nfs4acl.c and fs/nfsd/acl.h. Moreover, this header file introduces declaration of operations (nfsv4_ace_operations, nfsv4_ace_flags_operations, nfsv4_acl_id_operations, nfsv4_acl_mapping_operations) that can be specialized in concrete file system driver in the case of necessity. Otherwise, it is possible to use generalized mapping code without operations specialization. And, finally, it is declared nfsv4_acl_info structure that includes operations, pointer on mapping NFSv4 ACL and pointer on special mapping environment of concrete file system.
> 
> The essence of mapping algorithms (located in fs/nfsd/nfs4acl.c, previously) were generalized and moved in fs/nfs4acl.c with the purpose of sharing between file system drivers. A concrete file system driver can use mapping code by means of map_posix_acl_to_nfsv4_one(), map_nfsv4_acl_to_posix(), nfs4_acl_posix_to_nfsv4(), nfs4_acl_nfsv4_to_posix() methods. Also, it is possible to specialize internal mapping operations in the case of very special way of operations under raw structures for concrete file system driver case.
> 
> Mac OS X supports NFSv4 ACLs. It keeps its in the form of specially named xattr (com.apple.system.Security). HFS+ driver uses generalized implementation of NFSv4 ACLs <-> POSIX ACLs mapping algorithms. But it should be specialized internal mapping operations for the proper conversion of raw NFSv4 ACLs representation on HFS+ volume into POSIX ACLs. Thereby, it were implemented in hfsplus driver all necessary specialized internal mapping operations.

How does this make sense? There is no lossless mapping of NFSv4 acls
into POSIX acls; the latter doesn't have any equivalent of the DENY aces
so you cannot represent the full set of acls that can be set using MacOS
on the same filesystem.

Shouldn't you rather be looking at the richacl patch sets?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
