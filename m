Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55500 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794Ab2AKOsa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 09:48:30 -0500
Date: Wed, 11 Jan 2012 09:48:27 -0500
To: Andreas Dilger <adilger@whamcloud.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        ext4 development <linux-ext4@vger.kernel.org>,
        linux-fsdevel Devel <linux-fsdevel@vger.kernel.org>,
        Fan Yong <yong.fan@whamcloud.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Eric Sandeen <sandeen@redhat.com>
Subject: Re: [PATCH 0/4] [RESEND] 32/64 bit llseek hashes (v5)
Message-ID: <20120111144827.GA32381@fieldses.org>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
 <B5CFE283-4C3A-4C05-A779-05E2BE2EF5C6@whamcloud.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B5CFE283-4C3A-4C05-A779-05E2BE2EF5C6@whamcloud.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 10, 2012 at 04:27:15AM -0700, Andreas Dilger wrote:
> On 2012-01-09, at 6:21 AM, Bernd Schubert wrote:
> > With the ext3/ext4 directory index implementation hashes are used to specify
> > offsets for llseek(). For compatibility with NFSv2 and 32-bit user space
> > on 64-bit systems (kernel space) ext3/ext4 currently only return 32-bit 
> > hashes and therefore the probability of hash collisions for larger directories
> > is rather high. As recently reported on the NFS mailing list that theoretical
> > problem also happens on real systems:
> > http://comments.gmane.org/gmane.linux.nfs/40863
> > 
> > The following series adds two new f_mode flags to tell ext4
> > to use 32-bit or 64-bit hash values for llseek() calls.
> > These flags can then used by network file systems, such as NFS, to
> > request 32-bit or 64-bit offsets (hashes).
> 
> Ted, it would be great if these patches could land.  We hit issues like
> this previously as well, which is why we started this patch series in the
> first place.

Yes, this needs to be fixed--is there anything in particular holding up
these patches?

--b.
