Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35904 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750975AbdDRSde (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 14:33:34 -0400
Date: Tue, 18 Apr 2017 14:33:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Anna Schumaker <schumakeranna@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] Inter server-side copy performance
Message-ID: <20170418183333.GH6208@fieldses.org>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org>
 <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
 <20170417133604.GA22694@fieldses.org>
 <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
 <CAFX2JfkiraKm2Rmqhkrh3CSWBoYfW0QU=uXw=sSx-8Wt8JD7wg@mail.gmail.com>
 <CAN-5tyEO3wJ3sT_phM6LNGH3zpYmi21e+fhHjkSGvZrRqWziMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyEO3wJ3sT_phM6LNGH3zpYmi21e+fhHjkSGvZrRqWziMw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 18, 2017 at 01:28:39PM -0400, Olga Kornievskaia wrote:
> Given how the code is written now it looks like it's not possible to
> save up commits....
> 
> Here's what I can see happening:
> 
> nfs42_proc_clone() as well as nfs42_proc_copy() will call
> nfs_sync_inode(dst) "to make sure server(s) have the latest data"
> prior to initiating the clone/copy. So even if we just queue up (not
> send) the commit after the executing nfs42_proc_copy, then next call
> into vfs_copy_file_range() will send out that queued up commit.
> 
> Is it ok to relax the requirement that requirement, I'm not sure...

Well, if the typical case of copy_file_range is just opening a file,
doing a single big copy_file_range(), then closing the file, then this
doesn't matter.

The linux server is currently limiting COPY to 4MB at a time, which will
make the commits more annoying.

Even there the typical case will probably still be an open, followed by
a series of non-overlapping copies, then close, and that shouldn't
require the commits.

--b.
