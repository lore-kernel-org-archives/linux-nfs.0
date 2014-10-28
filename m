Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36991 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbaJ1VYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 17:24:42 -0400
Date: Tue, 28 Oct 2014 17:24:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/2] NFSD: Add v4.2 SEEK support
Message-ID: <20141028212441.GK32743@fieldses.org>
References: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20140926215431.GI27412@fieldses.org>
 <CAFX2Jfm2pDmz7vKPVNe8yZScVT-MvVD=+AsfOgdrPfKwgaLTXw@mail.gmail.com>
 <20141028210700.GI32743@fieldses.org>
 <545005EC.9030505@Netapp.com>
 <20141028211727.GJ32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141028211727.GJ32743@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 05:17:28PM -0400, J. Bruce Fields wrote:
> On Tue, Oct 28, 2014 at 05:09:00PM -0400, Anna Schumaker wrote:
> > On 10/28/2014 05:07 PM, J. Bruce Fields wrote:
> > > On Tue, Sep 30, 2014 at 01:00:24PM -0400, Anna Schumaker wrote:
> > >> I'm testing with xfstests #285.  It's an lseek specific test, and helped
> > >> find a few edge cases during development.
> > > 
> > > Any hints?  I did basically:
> > > 
> > > 	yum install xfsprogs-devel libattr-devel libacl-devel
> > > 	git clone git://oss.sgi.com/xfs/cmds/xfstests.git
> > > 	cd xfstests
> > > 	make
> > > 	make install
> > > 	cat >local.config <<EOF
> > > 	FSTYP=nfs
> > > 	TEST_DEV=f20-1:/exports/xfs/xfstests
> > > 	TEST_DIR=/mnt
> > > 	NFS_MOUNT_OPTIONS='-overs=4.2,sec=sys'
> > 
> > Try setting TEST_FS_MOUNT_OPTIONS instead of NFS_MOUNT_OPTIONS.
> 
> No change.--b.

(But TEST_FS_MOUNT_OPTS works.  How was I supposed to figure that out?)

--b.
