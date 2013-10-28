Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:13226 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab3J1AoR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 20:44:17 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>
Subject: Re: XATTRs in NFS?
Date: Mon, 28 Oct 2013 00:44:16 +0000
Message-ID: <2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com>
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
 <8DB0D7A2-BA2A-4001-A01C-D498C777B243@netapp.com>
 <1382920068.6932.46.camel@heisenberg.scientia.net>
In-Reply-To: <1382920068.6932.46.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 8:27 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Mon, 2013-10-28 at 00:17 +0000, Myklebust, Trond wrote:
>> ...and if the checksums are any good, then all you need to do to
>> substitute a database is to realise that a good data checksum is
>> invariant under renames.
> 
> Don't quite see what you mean...
> 
> Sure the checksums stay the same, but consider you have many millions of
> files, and you moved them around and thus the paths in the DB are
> incorrect... verifying the files will become very much a pain in the
> a**, especially when multiple files don't verify anymore.
> 
> Or what if you have many small similar files, where errors could lead to
> a checksum that was a correct one for another file,... when the paths
> are no longer valid you cannot know if this was a correct file or not.

If you have lots of small files, and you really do need to associate them uniquely with the checksum, then try something like:

	ln <filename> /path/to/database/<SHA512 identifier>.<inode number>

Hard links and inode numbers are also generally invariant under 'mv'.

Trond