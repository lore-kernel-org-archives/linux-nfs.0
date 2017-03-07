Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:4362 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933268AbdCGXuM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Mar 2017 18:50:12 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170307234345.GB29977@infradead.org>
Date: Tue, 7 Mar 2017 18:46:55 -0500
CC: "Darrick J. Wong" <darrick.wong@oracle.com>,
        <linux-fsdevel@vger.kernel.org>, <hch@lst.de>,
        <linux-nfs@vger.kernel.org>
Message-ID: <0E27E7C0-50AE-4E48-80BF-A9B6738BA4EC@netapp.com>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
 <20170302184057.GM26319@birch.djwong.org>
 <20170307234345.GB29977@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 7, 2017, at 6:43 PM, Christoph Hellwig <hch@infradead.org> =
wrote:
>=20
> On Thu, Mar 02, 2017 at 10:40:57AM -0800, Darrick J. Wong wrote:
>> Never mind, I misread vfs_copy as vfs_clone and thought you were =
talking
>> about something else. :(
>>=20
>> Sorry about the noise.
>=20
> And either way we'll need test coverage for copy_file_range before we
> do any more changes to it.  I'm sick and tired of this doctoring =
around
> without having any test coverage.  I've asked for it again and again
> and we've made very little progress despite having the code in the =
tree
> for almost a year and a half.


Anna has added test cases to the xfstest suite. Is there something =
that=E2=80=99s missing?=20=
