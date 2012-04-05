Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:44009 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab2DEQgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 12:36:15 -0400
Message-ID: <4F7DC9DC.6090802@cora.nwra.com>
Date: Thu, 05 Apr 2012 10:35:40 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: Dr James Bruce Fields <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
References: <1333040091.5547.32.camel@lade.trondhjem.org> <4F749CCA.3000400@cora.nwra.com> <1333042863.5547.37.camel@lade.trondhjem.org> <4F74A4D5.1040802@cora.nwra.com> <20120329193100.GA20329@fieldses.org> <1333052170.10318.6.camel@lade.trondhjem.org> <1333053750.10318.15.camel@lade.trondhjem.org> <20120329205035.GB21493@fieldses.org> <1333054622.10318.19.camel@lade.trondhjem.org> <20120329210838.GC21493@fieldses.org> <20120329211713.GD21493@fieldses.org>
In-Reply-To: <20120329211713.GD21493@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/29/2012 03:17 PM, Dr James Bruce Fields wrote:
> On Thu, Mar 29, 2012 at 05:08:38PM -0400, Dr James Bruce Fields wrote:
>> Anyway, something like the following (untested) should change v3 to
>> return nfs_ok in this case, and v4 to return the same errors it would on
>> a non-create open.
>
> Looking at the history, I think the v3 behavior has been there from the
> start.  I wonder why we've never gotten a bug report?
>
> Looking at wireshark.... I guess the client always does a lookup first,
> so we never hit this case (unless someone replaces the file by a
> non-regular-file between a lookup and a create?)
>
> --b.

So, is this all set to eventually make it into the mainline kernel?  Or is 
there still something I can do to help move it along?

Thanks everyone,

   Orion

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
