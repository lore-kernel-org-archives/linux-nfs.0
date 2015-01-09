Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:37202 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbbAIStr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2015 13:49:47 -0500
Date: Fri, 9 Jan 2015 19:49:43 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>, nfsv4@ietf.org
Subject: rfc5661 errata 3901, was: Re: [PATCH 09/18] nfsd: implement pNFS
	operations
Message-ID: <20150109184943.GA18955@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-10-git-send-email-hch@lst.de> <20150108164851.03b64e16@synchrony.poochiereds.net> <20150109100551.GA23173@lst.de> <20150109085130.0f862d24@synchrony.poochiereds.net> <20150109171641.GA17464@lst.de> <20150109092835.5fdbac5d@synchrony.poochiereds.net> <20150109093353.31a2e425@synchrony.poochiereds.net> <CAHQdGtQDK9bfgutRg4vqvRhdr8ewxFDy5a6bD_aVrqr6oH8Riw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQDK9bfgutRg4vqvRhdr8ewxFDy5a6bD_aVrqr6oH8Riw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 09:43:41AM -0800, Trond Myklebust wrote:
> >     [nfsv4] NFSv4.1 errata id 3226 (the return of return-on-close layouts)
> >
> > ...on thee nfsv4@ietf.org mailing list. Trond mentions it there.
> > Perhaps we need to revise that errata?
> >
> 
> Please see:
>      http://www.rfc-editor.org/errata_search.php?eid=3901

I think the language in this errata is very confusing, especially:

"After the client has closed all open stateids and returned the
delegation stateids for a file for which logr_return_on_close
was set to TRUE, the server MUST  invalidate all layout segments
that were  issued to the client for that file."

While the idea that return on close layouts should be valid as
long as the "parent" stateid is around make a lot of sense, this
requirement to track all open / delegation stateids per file/client
combination seems insane.

The only logical way to extend the original text is to require
layouts to be implicitly returned when:

 - the file is close for a layout stateid that is created based on
   the open or lock stateid
 - the delegation is returned for a layout stateid that is created
   based on the delegation stateid.

That is, only keep layouts opened based on the delegation stateid
alive over a close if they are hanging off that delegation stateid.
