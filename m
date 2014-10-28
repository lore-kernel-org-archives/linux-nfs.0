Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48696 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaJ1VHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 17:07:01 -0400
Date: Tue, 28 Oct 2014 17:07:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/2] NFSD: Add v4.2 SEEK support
Message-ID: <20141028210700.GI32743@fieldses.org>
References: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20140926215431.GI27412@fieldses.org>
 <CAFX2Jfm2pDmz7vKPVNe8yZScVT-MvVD=+AsfOgdrPfKwgaLTXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFX2Jfm2pDmz7vKPVNe8yZScVT-MvVD=+AsfOgdrPfKwgaLTXw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 30, 2014 at 01:00:24PM -0400, Anna Schumaker wrote:
> I'm testing with xfstests #285.  It's an lseek specific test, and helped
> find a few edge cases during development.

Any hints?  I did basically:

	yum install xfsprogs-devel libattr-devel libacl-devel
	git clone git://oss.sgi.com/xfs/cmds/xfstests.git
	cd xfstests
	make
	make install
	cat >local.config <<EOF
	FSTYP=nfs
	TEST_DEV=f20-1:/exports/xfs/xfstests
	TEST_DIR=/mnt
	NFS_MOUNT_OPTIONS='-overs=4.2,sec=sys'
	EOF
	./check -nfs generic/285

Passes just fine, but insists on using 4.0 and sec=krb5p, so apparently
NFS_MOUNT_OPTIONS is ignored.

I'm probably missing something basic, I haven't used xfstests before
(shame on me).

--b.
