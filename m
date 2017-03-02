Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:56914 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753217AbdCBRpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 12:45:22 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170302162221.GA6854@infradead.org>
Date: Thu, 2 Mar 2017 11:34:47 -0500
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <DC337EA9-5CCC-4C37-9FAD-E9DE8AFCF94A@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 2, 2017, at 11:22 AM, Christoph Hellwig <hch@infradead.org> =
wrote:
>=20
> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia wrote:
>> +	if (pos_in >=3D i_size_read(inode_in))
>> +		return -EINVAL;
>=20
> That's not how the syscall is supposed to work, we'd rather do a
> short read^^^^^copy.

This is when the offset from which to read is beyond the end of the =
file. I=E2=80=99m not sure what kind of short read are you expecting =
here.

