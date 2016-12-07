Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53412 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752342AbcLGOYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 09:24:30 -0500
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove
 nfs-config.service
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <748c0cb1-cc3b-362a-3c97-46917dd7dabc@RedHat.com>
 <87oa0o4r9m.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <351909cb-bdda-c3c9-cef2-e81b7eb6f66f@RedHat.com>
Date: Wed, 7 Dec 2016 09:24:28 -0500
MIME-Version: 1.0
In-Reply-To: <87oa0o4r9m.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2016 05:38 PM, NeilBrown wrote:
> On Wed, Dec 07 2016, Steve Dickson wrote:
> 
>> On 12/01/2016 10:58 PM, NeilBrown wrote:
>>> This is an RFC series.  A little voice at the back of my head keeps
>>> telling me that I'm over-engineering, but there isn't really that much
>>> new code, and I think the result has a lot to recommend it.
>>>
>>> But please tell me if I'm wrong.
>>>
>>> - Various daemons (not all) are enhance to accept configuration
>>>   information from /etc/nfs.conf
>>> - the conffile reader is enhanced to support include files, and
>>>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>>>   files usefully
>>> - nfs-config.service is removed, because it isn't really needed with
>>>   the above.
>>> - documentation for all the above is provided, including a new
>>>   nfs.systemd man page which gives the bigger picture.
>> This is some nice work! Its definitely a step in the right 
>> direction... IMHO... I especially like the idea of the include
>> statement, I'm very curious to see how that work! 
>>
>> If this is finished, I'll start testing and hopefully 
>> get it in... soon.
> 
> I would be happy for this to go in as-is.  There are certainly some
> changes needed (port, debug, host, etc) but they can be additions.
> I people are happy with the overall approach, then let's do it.
Sounds like a plan... 

steved.

> 
> Thanks,
> NeilBrown
> 
