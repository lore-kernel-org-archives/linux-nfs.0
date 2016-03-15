Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:33567 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755554AbcCOPqN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 11:46:13 -0400
Date: Tue, 15 Mar 2016 08:45:14 -0700
From: Jeremy Allison <jra@samba.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
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
Message-ID: <20160315154514.GB39038@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org>
 <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <20160315071103.GC19747@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160315071103.GC19747@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 12:11:03AM -0700, Christoph Hellwig wrote:
> On Fri, Mar 11, 2016 at 05:11:51PM +0100, Andreas Gruenbacher wrote:
> > > while breaking a lot of assumptions,
> > 
> > The model is designed specifically to be compliant with the POSIX
> > permission model. What assumptions are you talking about?
> 
> People have long learned that we only have 'alloc' permissions.  Any
> model that mixes allow and deny ACE is a mistake.

People can also learn and change though :-). One of the
biggest complaints people deploying Samba on Linux have is the
incompatible ACL models.

Whilst I have sympathy with your intense dislike of the
Windows ACL model, this comes down to the core of "who
do we serve ?" IMHO we should serve the users (although
I must confess I'd look awful in a TRON suit :-).
