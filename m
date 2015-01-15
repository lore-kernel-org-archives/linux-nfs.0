Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:32837 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbAOQaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jan 2015 11:30:15 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so15760934iec.12
        for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2015 08:30:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150115162618.GA14681@lst.de>
References: <1420561721-9150-10-git-send-email-hch@lst.de>
	<20150108164851.03b64e16@synchrony.poochiereds.net>
	<20150109100551.GA23173@lst.de>
	<20150109085130.0f862d24@synchrony.poochiereds.net>
	<20150109171641.GA17464@lst.de>
	<20150109092835.5fdbac5d@synchrony.poochiereds.net>
	<20150109093353.31a2e425@synchrony.poochiereds.net>
	<CAHQdGtQDK9bfgutRg4vqvRhdr8ewxFDy5a6bD_aVrqr6oH8Riw@mail.gmail.com>
	<20150109184943.GA18955@lst.de>
	<20150114191627.GA76105@kitty>
	<20150115162618.GA14681@lst.de>
Date: Thu, 15 Jan 2015 11:30:14 -0500
Message-ID: <CAABAsM4s4WA1oJD-Rz_xGRHfCQ49i0NvptDL_1taeXX7erPavw@mail.gmail.com>
Subject: Re: [nfsv4] rfc5661 errata 3901, was: Re: [PATCH 09/18] nfsd:
 implement pNFS operations
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 15, 2015 at 11:26 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Jan 14, 2015 at 11:16:27AM -0800, Tom Haynes wrote:
>> Christoph,
>>
>> I don't understand this concern. Section 8.2.1:
>>
>> open stateids: OPEN state for a given client ID/open-owner/filehandle triple
>>
>> delegation stateids: A stateid represents a single delegation held by a client for a
>>       particular filehandle.
>>
>> By definition, open/delegation stateids are tracked per
>> file/client combination.
>
> My concern is that the language in errata 3901 says the server should
> invalidate all layouts after all open stateids are closed, and all
> delegation stateids are returned for a given file, which means the
> server needs to add another object just to track the layouts.  If
> on the other hand we say the lifetime of the layouts is tied to
> the open stateid or the delegation stateid used to create the
> layout stateid we can track the outstanding layouts in those
> open/delegation stateid (and the lock stateid as well).
>

The problem, in my mind, is that defeats the main purpose of
return-on-close, which is to reduce the on-the-wire chattiness of the
protocol. How one implements that internally on the server is not
really a concern that should be reflected in the protocol.

Cheers
  Trond
