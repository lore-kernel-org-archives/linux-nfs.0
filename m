Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:48980 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314AbbAOQ0W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 11:26:22 -0500
Date: Thu, 15 Jan 2015 17:26:18 +0100
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>, nfsv4@ietf.org
Subject: Re: rfc5661 errata 3901, was: Re: [PATCH 09/18] nfsd: implement
	pNFS operations
Message-ID: <20150115162618.GA14681@lst.de>
References: <1420561721-9150-10-git-send-email-hch@lst.de> <20150108164851.03b64e16@synchrony.poochiereds.net> <20150109100551.GA23173@lst.de> <20150109085130.0f862d24@synchrony.poochiereds.net> <20150109171641.GA17464@lst.de> <20150109092835.5fdbac5d@synchrony.poochiereds.net> <20150109093353.31a2e425@synchrony.poochiereds.net> <CAHQdGtQDK9bfgutRg4vqvRhdr8ewxFDy5a6bD_aVrqr6oH8Riw@mail.gmail.com> <20150109184943.GA18955@lst.de> <20150114191627.GA76105@kitty>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150114191627.GA76105@kitty>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 11:16:27AM -0800, Tom Haynes wrote:
> Christoph,
> 
> I don't understand this concern. Section 8.2.1:
> 
> open stateids: OPEN state for a given client ID/open-owner/filehandle triple
> 
> delegation stateids: A stateid represents a single delegation held by a client for a
>       particular filehandle.
> 
> By definition, open/delegation stateids are tracked per
> file/client combination.

My concern is that the language in errata 3901 says the server should
invalidate all layouts after all open stateids are closed, and all
delegation stateids are returned for a given file, which means the
server needs to add another object just to track the layouts.  If
on the other hand we say the lifetime of the layouts is tied to
the open stateid or the delegation stateid used to create the
layout stateid we can track the outstanding layouts in those
open/delegation stateid (and the lock stateid as well).
