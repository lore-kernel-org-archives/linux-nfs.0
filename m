Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:58612 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbbBPXGH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2015 18:06:07 -0500
Received: by mail-vc0-f180.google.com with SMTP id im6so11480089vcb.11
        for <linux-nfs@vger.kernel.org>; Mon, 16 Feb 2015 15:06:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150216201751.GB22154@fieldses.org>
References: <20150216122107.4bfd4225@notabene.brown>
	<20150216201751.GB22154@fieldses.org>
Date: Mon, 16 Feb 2015 18:06:06 -0500
Message-ID: <CAHQdGtT+xq4uFfjxvDXgG+Oe4NvNCjj0ngmGftTVfherqwJxXQ@mail.gmail.com>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 16, 2015 at 3:17 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Feb 16, 2015 at 12:21:07PM +1100, NeilBrown wrote:
>>
>>
>> - note that 'nohide' is irrelevant for NFSv4
>> - note that children on a 'crossmnt' filesystem cannot be unexported
>> - note that 'nocrossmnt' is a valid option, but probably not useful.
>>
>> Signed-off-by: NeilBrown <neilb@suse.de>
>>
>> ---
>>
>> I wonder if we should add a new option, e.g. "noaccess" so that children
>> of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
>> know about this.  It would just tell mountd to refuse to export that
>> filesystem even if the parent was "crossmnt".
>> ??
>
> Seems logical enough, but I can't recall seeing requests for it, and
> the options here already seem complicated enough.
>
> In theory something like that could also be done with namespaces.  (So,
> run mountd in a separate mount namespace that lacks those children.)

Agreed. It seems unnecessarily complicated to add yet another option
to the crossmnt/nohide saga. If the "nohide" documentation is too
complex, then we should rather aim to improve that documentation.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
