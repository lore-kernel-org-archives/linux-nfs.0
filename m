Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55167 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751196AbdLSRKv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 12:10:51 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: bfields@fieldses.org, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: permit layoutget of executable-only files
Date: Tue, 19 Dec 2017 12:10:48 -0500
Message-ID: <9AE719FA-9D3F-447E-969A-9A1BA908BE1D@redhat.com>
In-Reply-To: <1513699256.129904.3.camel@primarydata.com>
References: <2f621da7f3633e5a127ac89d886738c35ea02880.1513693981.git.bcodding@redhat.com>
 <20171219154330.GA19967@fieldses.org>
 <1513699256.129904.3.camel@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19 Dec 2017, at 11:00, Trond Myklebust wrote:

> On Tue, 2017-12-19 at 10:43 -0500, J. Bruce Fields wrote:
>> On Tue, Dec 19, 2017 at 09:35:25AM -0500, Benjamin Coddington wrote:
>>> Clients must be able to read a file in order to execute it, and for
>>> pNFS
>>> that means the client needs to be able to perform a LAYOUTGET on
>>> the file.
>>>
>>> This behavior for executable-only files was added for OPEN in
>>> commit
>>> a043226bc140 "nfsd4: permit read opens of executable-only files".
>>>
>>> This fixes up xfstests generic/126 on block/scsi layouts.
>>
>> Thanks, applied.  So the server was returning NFS4ERR_ACCESS and the
>> client was returning that to the application?  I was wondering for a
>> moment whether the client should instead try falling back to MDS IO,
>> but.... But I don't think that makes sense.  The client's probably
>> correct to interpret ACCESS as just meaning that user can't read the
>> file.  The server has plenty of other errors to choose from if it
>> just
>> wants to deny the layout for some reason.  OK.
>>
>
> There are several errors which can be returned by LAYOUTGET, and which
> the client will pass back to the application. NFS4ERR_ACCESS is one.

And just to be perfectly clear, yes, that's what I see.

Ben
