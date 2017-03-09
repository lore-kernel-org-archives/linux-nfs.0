Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:17615 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753277AbdCIR2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 12:28:13 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170309161729.GA11655@infradead.org>
Date: Thu, 9 Mar 2017 12:28:03 -0500
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-ID: <480EF075-69E6-458D-AA5F-FBE19F68C3C3@netapp.com>
References: <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
 <1489004308.3098.10.camel@primarydata.com>
 <20170308203236.GC3492@fieldses.org>
 <1489006194.3098.12.camel@primarydata.com>
 <20170309152948.GB3929@fieldses.org> <20170309153559.GA20205@infradead.org>
 <20170309161601.GC3929@fieldses.org> <20170309161729.GA11655@infradead.org>
To: "hch@infradead.org" <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 9, 2017, at 11:17 AM, hch@infradead.org wrote:
>=20
> On Thu, Mar 09, 2017 at 11:16:01AM -0500, bfields@fieldses.org wrote:
>> I guess I'm just hung up on the EINVAL vs. short copy behavior.  It
>> seems more annoying and error-prone to be prepared for both, as =
opposed
>> to trying clone and then explicitly falling back to copy if that =
doesn't
>> work.  Maybe it's not that big a deal.
>=20
> We can do short copies^H^H^H^H^Hclones for clone just as easily,
> at least for local filesystems (NFS would require some tweaks due to =
the
> protocol).

I=E2=80=99m confused by the wording of =E2=80=9Cwe can do =E2=80=A6 =
easily=E2=80=9D . Is =E2=80=9Ccan=E2=80=9D =3D in the future? Currently, =
testing copy_file_range() on a btfs with argument of offset+len beyond =
the end of the file fail with EINVAL. Is NFS tweaking =3D revert the =
=E2=80=9CMUST=E2=80=9D in the spec for the check?=20



