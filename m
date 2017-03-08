Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:62082 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752157AbdCHReD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 12:34:03 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170308172549.GA32011@infradead.org>
Date: Wed, 8 Mar 2017 12:32:12 -0500
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
 <20170307234051.GA29977@infradead.org> <20170308170521.GA1020@fieldses.org>
 <20170308172549.GA32011@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 8, 2017, at 12:25 PM, Christoph Hellwig <hch@infradead.org> =
wrote:
>=20
> On Wed, Mar 08, 2017 at 12:05:21PM -0500, J. Bruce Fields wrote:
>> Since copy isn't atomic that check is never going to be reliable.
>=20
> That's true for everything that COPY does.  By that logic we should
> not implement it at all (a logic that I'd fully support)


If you were to only keep CLONE then you=E2=80=99d lose a huge =
performance gain you get from server-to-server COPY.=20=
