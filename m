Return-Path: bfields@fieldses.org
Date: Tue, 18 Nov 2014 12:02:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141118170210.GG7419@fieldses.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
 <20141106201341.GD22638@fieldses.org>
 <20141107072637.GA25215@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141107072637.GA25215@infradead.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 06, 2014 at 11:26:37PM -0800, Christoph Hellwig wrote:
> Note that for filesystems natively implementing the change attribute
> (btrfs, XFSv5 and ext4 with a mount option) there is no difference anyway,

Is there something special I have to do to get this on xfs?

My change attribute test sends a compound that alternates several
SETATTRs of the mode with GETATTRS of the change attribute and complains
if the change attribute doesn't change each time.

That's still failing on F20 on a filesystem created with just mkfs.xfs.

--b.
