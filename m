Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbbKJTRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2015 14:17:46 -0500
Date: Tue, 10 Nov 2015 14:17:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Steve French <smfrench@gmail.com>, Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v15 00/22] Richacls (Core and Ext4)
Message-ID: <20151110191745.GA19379@fieldses.org>
References: <1447067343-31479-1-git-send-email-agruenba@redhat.com>
 <20151110112943.GA17038@infradead.org>
 <CAHc6FU5g7=wd1Wt4+GCaLJjNu7giruZyAON3VcYn-A=ffYMsmw@mail.gmail.com>
 <CAH2r5ms1ckC59o9sbBEBAWQA0Q3tGOs=YJpk01xg19zThJDt-w@mail.gmail.com>
 <20151110170703.GB17530@fieldses.org>
 <CAHc6FU6aWsWO1SOSyNVnbObE0GoE4dr5a3WVTgvX4xn0wum1Fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU6aWsWO1SOSyNVnbObE0GoE4dr5a3WVTgvX4xn0wum1Fg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2015 at 06:58:19PM +0100, Andreas Gruenbacher wrote:
> On Tue, Nov 10, 2015 at 6:07 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Nov 10, 2015 at 10:43:46AM -0600, Steve French wrote:
> >> I don't have strong disagreement with using pseudo-xattrs to
> >> store/retrieve ACLs (we already do this) but retrieving/setting an ACL
> >> all at once can be awkward  when ACLs are quite large e.g. when it
> >> encodes to over 1MB
> >
> > At least in the NFS case, that's also a limitation of the protocol.
> 
> I couldn't find a limit in the NFSv4 specification, but the client and
> server implementations both define arbitrary ACL size limits. In
> addition, the xattr syscalls allow attributes to be up to 64k long.

I don't recall 4.0 specifying any limit, 4.1 does include negotiation of
maximum rpc calls and replies, and that effectively limits ACL sizes
since they have to fit in a single rpc.

> The bigger problem would be incrementally setting ACLs. To prevent
> processes from racing with each other, we would need a locking
> mechanism. In addition, the memory overhead would be prohibitive and
> access decisions would become extremely slow; we would have to come up
> with mechanisms to avoid those problems.

Right.  Anyway, not worth the trouble, I think.

(Though what might be worth thinking about at some point is just making
sure we fail in helpful ways.)

--b.
