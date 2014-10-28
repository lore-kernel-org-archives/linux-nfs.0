Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:12166 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbaJ1VJM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 17:09:12 -0400
Message-ID: <545005EC.9030505@Netapp.com>
Date: Tue, 28 Oct 2014 17:09:00 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/2] NFSD: Add v4.2 SEEK support
References: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com> <20140926215431.GI27412@fieldses.org> <CAFX2Jfm2pDmz7vKPVNe8yZScVT-MvVD=+AsfOgdrPfKwgaLTXw@mail.gmail.com> <20141028210700.GI32743@fieldses.org>
In-Reply-To: <20141028210700.GI32743@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2014 05:07 PM, J. Bruce Fields wrote:
> On Tue, Sep 30, 2014 at 01:00:24PM -0400, Anna Schumaker wrote:
>> I'm testing with xfstests #285.  It's an lseek specific test, and helped
>> find a few edge cases during development.
> 
> Any hints?  I did basically:
> 
> 	yum install xfsprogs-devel libattr-devel libacl-devel
> 	git clone git://oss.sgi.com/xfs/cmds/xfstests.git
> 	cd xfstests
> 	make
> 	make install
> 	cat >local.config <<EOF
> 	FSTYP=nfs
> 	TEST_DEV=f20-1:/exports/xfs/xfstests
> 	TEST_DIR=/mnt
> 	NFS_MOUNT_OPTIONS='-overs=4.2,sec=sys'

Try setting TEST_FS_MOUNT_OPTIONS instead of NFS_MOUNT_OPTIONS.

> 	EOF
> 	./check -nfs generic/285
> 
> Passes just fine, but insists on using 4.0 and sec=krb5p, so apparently
> NFS_MOUNT_OPTIONS is ignored.
> 
> I'm probably missing something basic, I haven't used xfstests before
> (shame on me).
> 
> --b.
> 

