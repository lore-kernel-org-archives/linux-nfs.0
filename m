Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:40405 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757248AbaD1X6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 19:58:53 -0400
Date: Tue, 29 Apr 2014 09:58:49 +1000
From: Dave Chinner <david@fromorbit.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 00/22]  New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20140428235849.GN15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20140427222019.GF15995@dastard>
 <87zjj6auvv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87zjj6auvv.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 28, 2014 at 10:54:52AM +0530, Aneesh Kumar K.V wrote:
> Dave Chinner <david@fromorbit.com> writes:
> > On Sun, Apr 27, 2014 at 09:44:31PM +0530, Aneesh Kumar K.V wrote:
> >> Hi
> >> 
> >> As per LSF/MM summit discussion I am reposting the richacl patchset for
> >> upstream inclusion. The patchset includes minimal changes required to implement
> >> a new acl model similar to NFSv4 ACL. The acl model selection is based on
> >> file system feature flag. 
> >> 
> >> The following set of patches implements VFS and ext4 changes needed to implement
> >> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> >> extended by file masks to fit into the standard POSIX file permission model.
> >> They are designed to work seamlessly locally as well as across the NFSv4 and
> >> CIFS/SMB2 network file system protocols.
> >> 
> >> A user-space utility for displaying and changing richacls is available at [1]
> >> (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
....
> >> More details regarding richacl can be found at
> >> http://acl.bestbits.at/richacl/
> >> 
> >> Previous posting of the patchset can be found at:
> >> http://mid.gmane.org/1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> >> "[PATCH -V8 00/26]  New ACL format for better NFSv4 acl interoperability"
> >> 
> >> The complete patchset can also be found at:
> >> https://github.com/kvaneesh/linux/commits/richacl-for-upstream
> >
> > Where are the tests? We need comprehensive coverage in xfstests so
> > we can validate that it works the way it is supposed to and that we
> > don't break it in future, and that all filesystems behave the same
> > way....
> >
> 
> https://github.com/kvaneesh/richacl-tools/tree/master/test

FYI, I doubt very much that anyone will run a stand-alone richacls
test suite regularly.  Can you please work to integrate this into
xfstests so it becomes a regular part of a filesystem developer's
daily workflow?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
