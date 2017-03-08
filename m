Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:26852 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752998AbdCHPku (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 10:40:50 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170307235058.GA9879@infradead.org>
Date: Wed, 8 Mar 2017 10:39:11 -0500
CC: "Darrick J. Wong" <darrick.wong@oracle.com>,
        <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        <linux-nfs@vger.kernel.org>
Message-ID: <1523DC5D-A162-4EB7-AAD7-F0C1BF8B57A8@netapp.com>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
 <20170302184057.GM26319@birch.djwong.org>
 <20170307234345.GB29977@infradead.org>
 <0E27E7C0-50AE-4E48-80BF-A9B6738BA4EC@netapp.com>
 <20170307235058.GA9879@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 7, 2017, at 6:50 PM, Christoph Hellwig <hch@infradead.org> =
wrote:
>=20
> On Tue, Mar 07, 2017 at 06:46:55PM -0500, Olga Kornievskaia wrote:
>> Anna has added test cases to the xfstest suite. Is there something =
that=E2=80=99s missing?=20
>=20
> No, we still don't have that.  Anna did one attempt (or maybe two) but
> didn't seem to have time to follow up the review comments.  Maybe you
> can give it a spin to make sure we at least have basic test coverage,
> including the cases mentioned in the man page like this.

I=E2=80=99m reading some mail archives and I see that Anna submitted =
patches for xfstests. The comment was to re-work it as a part of xfs_io =
command. She posted the patches for that. According to the announcement =
I see here: http://oss.sgi.com/archives/xfs/2016-08/msg00221.html it =
says it=E2=80=99s including the new copy_file_range command in xfs_io. I =
don=E2=80=99t run these tests so I don=E2=80=99t know but it look to me =
that the tests are in.

Can you please what I=E2=80=99m getting wrong?

Thank you.



