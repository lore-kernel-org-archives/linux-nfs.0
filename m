Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32963 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab3J1ATM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 20:19:12 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Eshel Marc <eshel@us.ibm.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "Wheeler Ric" <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Mon, 28 Oct 2013 00:19:10 +0000
Message-ID: <E5AAC597-053A-4150-9041-32885CFFC6C4@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
 <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com>
 <7C1323EE-D63F-4F93-A44D-E7DDB0C61BF0@netapp.com>
 <OF01D9818B.36018C0F-ON88257C10.00608BC0-88257C10.006139C6@LocalDomain>
 <OF7F1977B0.3BF0FF3B-ON88257C10.00618038-88257C10.0061AF59@us.ibm.com>
 <4260556F-D57B-407E-A686-808D3D802137@netapp.com>
 <1382919289.6932.35.camel@heisenberg.scientia.net>
In-Reply-To: <1382919289.6932.35.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 27, 2013, at 8:14 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Sun, 2013-10-27 at 12:48 +0000, Myklebust, Trond wrote:
>> Let's get the basic discussion of motivation right first.
> Actually I might know another use case.
> 
> dCache[0] which implements a (p)NFS 4.1 server and is heavily used
> within the high energy physics community, could benefit from XATTRs as
> well.
> 
> Ever since, dCache has had a concept called PNFS tags (where the PNFS
> had nothing to do with parallel NFS, but is called so for other
> historical reasons), which are basically key/value pairs belonging to
> some file (well at least directory, I don't remember where PNFS tags
> exist for regular files).
> 
> These tags are used to control several things, indirectly, e.g. to which
> data pool node a file may go, and via that whether it may be moved to
> tape, whether it is duplicated, etc. pp.
> 
> Since there were no XATTRs (at least I guess that's the historical
> reason), they used special files for this having the name:
> ".(tag)(key)" and the content of the file is the value.
> 
> So for a path,
> /data/foo/bar/
> one can set the key "sGroup" (aka storage group) to a value say
> "ATLAS" (which (very simplified) will tell dCache in the end that this
> is storage belonging to the ATLAS experiment) by creating a file
> echo "ATLAS" > '/data/foo/bar/.(tag)(sGroup)'
> 
> 
> Obviously having such special files isn't that nice, and having real
> XATTRs would be the better solution.

Ordinary groups can do the same.

Trond