Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755447AbZHYReH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 13:34:07 -0400
Message-ID: <4A942089.1010102@RedHat.com>
Date: Tue, 25 Aug 2009 13:34:01 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Lans Carstensen <Lans.Carstensen@dreamworks.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [NFS] [PATCH] nfs-utils: nfs-iostat.py option to sort by ops/s
References: <4A93214A.5000404@dreamworks.com> <009376AC-B08B-4E90-A46B-E5BC069A5A78@oracle.com>
In-Reply-To: <009376AC-B08B-4E90-A46B-E5BC069A5A78@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/25/2009 12:29 PM, Chuck Lever wrote:
> [ Cc: changed to correct mailing list.  sf.net list is deprecated. ]
> 
> On Aug 24, 2009, at 7:24 PM, Lans Carstensen wrote:
>> Hi,
>>
>> I've recently made tools/nfs-iostat/nfs-iostat.py more useful in our
>> autofs environment with a variety of cleanups and am offering this
>> patch up for discussion and/or inclusion in nfs-utils.  It does the
>> following:
>>
>> * Adds a --top flag to sort the display of mountpoint entries by ops/s.
>> * Adds a --<n> flag to only display stats for the first <n> mountpoints
>> * Re-reads the mountpoint list on intervals since it's dynamic in an
>>  autofs environment.
>> * Conforms the Python path to the LSB 3.2+ standard of /usr/bin/python
>> http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages/pylocation.html
>>
> 
> A couple of overall comments.
> 
> 1.  These seem to be logically independent changes, so we would prefer
> them in separate patches.  Each logical change can be refined and voted
> up or down separately.
I guess you could break this up into more patches... but overall its
by no means unruly.... 

> 
> 2.  Sorting by ops is OK, but not sure about "--top".  Since the script
> doesn't generate a curses like display like "top" does, maybe "--sort
> <n>" would be a better name, and --top and --<n> could be combined.
Hmm.. I kinda like like the --top flag... its pretty descriptive to
what it does..
 
> 
> 3.  The distributors should weigh in on the Python path change.
Using '#!/usr/bin/python' is better than '#!/usr/bin/env python'
since you know exactly which python binary you will be using.
It was also pointed out the env convention will confuse 
rpm's dependency generator

steved.
