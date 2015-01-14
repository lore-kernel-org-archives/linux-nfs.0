Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:57299 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbbANTQd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 14:16:33 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so11477263pdi.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 11:16:33 -0800 (PST)
Date: Wed, 14 Jan 2015 11:16:27 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>, nfsv4@ietf.org
Subject: Re: rfc5661 errata 3901, was: Re: [PATCH 09/18] nfsd: implement pNFS
 operations
Message-ID: <20150114191627.GA76105@kitty>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-10-git-send-email-hch@lst.de>
 <20150108164851.03b64e16@synchrony.poochiereds.net>
 <20150109100551.GA23173@lst.de>
 <20150109085130.0f862d24@synchrony.poochiereds.net>
 <20150109171641.GA17464@lst.de>
 <20150109092835.5fdbac5d@synchrony.poochiereds.net>
 <20150109093353.31a2e425@synchrony.poochiereds.net>
 <CAHQdGtQDK9bfgutRg4vqvRhdr8ewxFDy5a6bD_aVrqr6oH8Riw@mail.gmail.com>
 <20150109184943.GA18955@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150109184943.GA18955@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 07:49:43PM +0100, Christoph Hellwig wrote:
> On Fri, Jan 09, 2015 at 09:43:41AM -0800, Trond Myklebust wrote:
> > >     [nfsv4] NFSv4.1 errata id 3226 (the return of return-on-close layouts)
> > >
> > > ...on thee nfsv4@ietf.org mailing list. Trond mentions it there.
> > > Perhaps we need to revise that errata?
> > >
> > 
> > Please see:
> >      http://www.rfc-editor.org/errata_search.php?eid=3901
> 
> I think the language in this errata is very confusing, especially:
> 
> "After the client has closed all open stateids and returned the
> delegation stateids for a file for which logr_return_on_close
> was set to TRUE, the server MUST  invalidate all layout segments
> that were  issued to the client for that file."
> 
> While the idea that return on close layouts should be valid as
> long as the "parent" stateid is around make a lot of sense, this
> requirement to track all open / delegation stateids per file/client
> combination seems insane.

Christoph,

I don't understand this concern. Section 8.2.1:

open stateids: OPEN state for a given client ID/open-owner/filehandle triple

delegation stateids: A stateid represents a single delegation held by a client for a
      particular filehandle.

By definition, open/delegation stateids are tracked per
file/client combination.

> 
> The only logical way to extend the original text is to require
> layouts to be implicitly returned when:
> 
>  - the file is close for a layout stateid that is created based on
>    the open or lock stateid

I read you as saying that on the first CLOSE, the layout must
be returned. This seems very burdensome in that the client is aware
that other OPENs may have occured and expects to be able to still
utilize the layout. Under this new model, it would need to get
the layout again.

I.e., Trond's orginal concern with Section 18.43.3 is just that,
the text states that:

   The logr_return_on_close result field is a directive to return the
   layout before closing the file.

Paraphrasing the errata, this could be rewritten as

   The logr_return_on_close result field is a directive to return the
   layout before the last close of the file.

>  - the delegation is returned for a layout stateid that is created
>    based on the delegation stateid.

This agrees with the paragraph above.

> 
> That is, only keep layouts opened based on the delegation stateid
> alive over a close if they are hanging off that delegation stateid.

Thanks,
Tom
