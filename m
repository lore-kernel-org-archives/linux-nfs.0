Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:56448 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab2DEURe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 16:17:34 -0400
Message-ID: <4F7DFDD7.30005@cora.nwra.com>
Date: Thu, 05 Apr 2012 14:17:27 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
References: <1333042863.5547.37.camel@lade.trondhjem.org> <4F74A4D5.1040802@cora.nwra.com> <20120329193100.GA20329@fieldses.org> <1333052170.10318.6.camel@lade.trondhjem.org> <1333053750.10318.15.camel@lade.trondhjem.org> <20120329205035.GB21493@fieldses.org> <1333054622.10318.19.camel@lade.trondhjem.org> <20120329210838.GC21493@fieldses.org> <20120329211713.GD21493@fieldses.org> <4F7DC9DC.6090802@cora.nwra.com> <20120405165311.GA11707@fieldses.org>
In-Reply-To: <20120405165311.GA11707@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/05/2012 10:53 AM, Bruce Fields wrote:
> On Thu, Apr 05, 2012 at 10:35:40AM -0600, Orion Poplawski wrote:
>> On 03/29/2012 03:17 PM, Dr James Bruce Fields wrote:
>>> On Thu, Mar 29, 2012 at 05:08:38PM -0400, Dr James Bruce Fields wrote:
>>>> Anyway, something like the following (untested) should change v3 to
>>>> return nfs_ok in this case, and v4 to return the same errors it would on
>>>> a non-create open.
>>>
>>> Looking at the history, I think the v3 behavior has been there from the
>>> start.  I wonder why we've never gotten a bug report?
>>>
>>> Looking at wireshark.... I guess the client always does a lookup first,
>>> so we never hit this case (unless someone replaces the file by a
>>> non-regular-file between a lookup and a create?)
>>>
>>> --b.
>>
>> So, is this all set to eventually make it into the mainline kernel?
>> Or is there still something I can do to help move it along?
>
> If you could confirm whether the patch in
>
> 	http://www.spinics.net/lists/linux-nfs/msg28840.html
>
> fixes your problem, that would help.
>
> --b.

I applied it to 2.6.32-220.7.1.el6.x86_64 and it appears to have fixed the 
issue.  Can't be sure yet if it broke anything else though...


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
