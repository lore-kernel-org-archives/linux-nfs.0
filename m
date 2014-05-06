Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbaEFUPc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 16:15:32 -0400
Date: Tue, 6 May 2014 16:15:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 00/22]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20140506201503.GN18281@fieldses.org>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 27, 2014 at 09:44:31PM +0530, Aneesh Kumar K.V wrote:
> As per LSF/MM summit discussion I am reposting the richacl patchset for
> upstream inclusion. The patchset includes minimal changes required to implement
> a new acl model similar to NFSv4 ACL. The acl model selection is based on
> file system feature flag. 

It'd also be nice to see the nfsd bits, as that (along with samba) is
one of the main users.

(And the richacl->NFSv4 acl mapping is tricky thanks to the mask bits.)

--b.

> 
> The following set of patches implements VFS and ext4 changes needed to implement
> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> extended by file masks to fit into the standard POSIX file permission model.
> They are designed to work seamlessly locally as well as across the NFSv4 and
> CIFS/SMB2 network file system protocols.
> 
> A user-space utility for displaying and changing richacls is available at [1]
> (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
> 
> [1] git://github.com/kvaneesh/richacl-tools.git master
> 
> To test richacl on ext4, create the file sytem with richacl feature flag
> (mkfs.ext4 -O richacl or  tune2fs -O richacl). With richacl feature enabled
> using mount option "acl" will switch to using richacl instead of posixacl.
> 
> More details regarding richacl can be found at
> http://acl.bestbits.at/richacl/
> 
> Previous posting of the patchset can be found at:
> http://mid.gmane.org/1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> "[PATCH -V8 00/26]  New ACL format for better NFSv4 acl interoperability"
> 
> The complete patchset can also be found at:
> https://github.com/kvaneesh/linux/commits/richacl-for-upstream
> 
> Since we are trying to get the changes merged upstream after a long time, I am
> posting this as V1 again. I Also dropped the Acked-by tag from
> David Howells <dhowells@redhat.com> and J. Bruce Fields <bfields@redhat.com>.
> Please let me know if I can add them back again.
> 
> -aneesh
> 
