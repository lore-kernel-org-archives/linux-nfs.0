Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.SerNet.de ([193.175.80.2]:49005 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147AbcCOUjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 16:39:12 -0400
Date: Tue, 15 Mar 2016 21:17:00 +0100
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: Cristoph Hellwig <hch@infradead.org>
Cc: Jeremy Allison <jra@samba.org>, Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
Message-ID: <20160315201700.GA22945@sernet.de>
Reply-To: Volker.Lendecke@SerNet.DE
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org>
 <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <20160315071103.GC19747@infradead.org>
 <20160315154514.GB39038@jra3>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160315154514.GB39038@jra3>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 08:45:14AM -0700, Jeremy Allison wrote:
> On Tue, Mar 15, 2016 at 12:11:03AM -0700, Christoph Hellwig wrote:
> > People have long learned that we only have 'alloc' permissions.  Any
> > model that mixes allow and deny ACE is a mistake.
> 
> People can also learn and change though :-). One of the
> biggest complaints people deploying Samba on Linux have is the
> incompatible ACL models.

Just to confirm: I see this a lot in the field. NFSv4 ACLs, while not a
perfect match for NTFS ACLs are a lot closer much more usable to people
who want to serve Windows clients.

Also in the pure linux world there is a lot that you can not express
with just rwx, sgid, sticky bits and friends. If you want the additional
functionality of the richacl bits, I would call it a big mistake to
omit negative aces, if just for the reason not to create yet another
ACLs flavor.

> Whilst I have sympathy with your intense dislike of the
> Windows ACL model, this comes down to the core of "who
> do we serve ?"

The world has enough confusion around ACL semanics, please do not add
more to it by creating your own model of the day.

Volker
