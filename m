Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:58794 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753818AbdCHUzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 15:55:19 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170308195327.GA3492@fieldses.org>
Date: Wed, 8 Mar 2017 15:00:52 -0500
CC: Christoph Hellwig <hch@infradead.org>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>
Message-ID: <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
 <20170307234051.GA29977@infradead.org> <20170308170521.GA1020@fieldses.org>
 <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 8, 2017, at 2:53 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Wed, Mar 08, 2017 at 12:32:12PM -0500, Olga Kornievskaia wrote:
>>=20
>>> On Mar 8, 2017, at 12:25 PM, Christoph Hellwig <hch@infradead.org>
>>> wrote:
>>>=20
>>> On Wed, Mar 08, 2017 at 12:05:21PM -0500, J. Bruce Fields wrote:
>>>> Since copy isn't atomic that check is never going to be reliable.
>>>=20
>>> That's true for everything that COPY does.  By that logic we should
>>> not implement it at all (a logic that I'd fully support)
>>=20
>> If you were to only keep CLONE then you=E2=80=99d lose a huge =
performance gain
>> you get from server-to-server COPY.=20
>=20
> Yes.  Also, I think copy-like copy implementations have reasonable
> semantics that are basically the same as read:
>=20
> 	- copy can return successfully with less copied than requested.
> 	- it's fine for the copied range to start and/or end past end of
> 	  file, it'll just return a short read.
> 	- A copy of more than 0 bytes returning 0 means you're at end of
> 	  file.
>=20
> The particular problem here is that that doesn't fit how clone works =
at
> all.
>=20
> It feels like what happened is that copy_file_range() was made mainly
> for the clone case, with the idea that copy might be reluctantly
> accepted as a second-class implementation.
>=20
> But the performance gain of copy offload is too big to just ignore, =
and
> in fact it's what copy_file_range does on every filesystem but btrfs =
and
> ocfs2 (and maybe cifs?), so I don't think we can just ignore it.
>=20
> If we had separate copy_file_range and clone_file_range, I *think* it
> could all be made sensible.  Am I missing something?
>=20

How would the application (cp) know when to call the clone_file_range =
and when to call copy_file_range?
=20

