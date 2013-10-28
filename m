Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:64436 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab3J1ARv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 20:17:51 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>
Subject: Re: XATTRs in NFS?
Date: Mon, 28 Oct 2013 00:17:14 +0000
Message-ID: <8DB0D7A2-BA2A-4001-A01C-D498C777B243@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
 <20131025140846.GB20497@fieldses.org>
 <1382807547.29041.12.camel@heisenberg.scientia.net>
 <20131027191512.GA31322@fieldses.org>
 <1382911068.6932.20.camel@heisenberg.scientia.net>
In-Reply-To: <1382911068.6932.20.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 5:57 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Sun, 2013-10-27 at 15:15 -0400, J. Bruce Fields wrote:
>> Was this problem actually caught using checksums stored in xattrs, or
>> did the problem predate your use of xattrs?
> Phew... don't remember actually... but I think I haven't used that
> already back then and noticed it by chance when I did some diffs.
> 
> 
>>> So the idea of my integrity data is, that I really manually say "now the
>>> data is in the state where I consider it to be consistent and I want to
>>> have checksums stored and attached to the files, for exactly that
>>> state", e.g. after I have read out some images from the SD card (perhaps
>>> even twice with the cache cleared and the results diffed) and placed in
>>> my archive.
>>> Afterwards I can regularly verify the whole archive and if at some stage
>>> corruptions as the above would have happened, I can simply take the
>>> respective files from backups.
>> How long have you been using this for?
> Uhm... about 3-4 years now.
> 
>> How many problems has it caught?
> I do not keep exact statistics... but I remember a few cases where I
> found damaged backups (optimal media) which I replaced as a consequence.
> 
>> How often do you checksum or verify files, and how expensive is that?
> Not that often,... on my actual data disks,... about every 4 months...
> on my backup media (I use to keep older generations of backups as well)
> about once a year.
> 
> I've never really looked at how expensive it is,... all you need to do
> is simply reading all data + have their hashes calculated.

...and if the checksums are any good, then all you need to do to substitute a database is to realise that a good data checksum is invariant under renames.

