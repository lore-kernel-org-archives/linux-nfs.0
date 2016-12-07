Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58448 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751064AbcLGOo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 09:44:26 -0500
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
 <87r35k4rcr.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com>
Date: Wed, 7 Dec 2016 09:44:25 -0500
MIME-Version: 1.0
In-Reply-To: <87r35k4rcr.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2016 05:36 PM, NeilBrown wrote:
> On Wed, Dec 07 2016, Steve Dickson wrote:
> 
>>> +.B nfsd
>>> +Recognized values:
>>> +.BR threads ,
>>> +.BR grace-time ,
>>> +.BR lease-time ,
>>> +.BR udp ,
>>> +.BR tcp ,
>>> +.BR vers2 ,
>>> +.BR vers3 ,
>>> +.BR vers4 ,
>>> +.BR vers4.0 ,
>> Do we need both ver4 and ver4.0?
> 
> "vers4" allows you to enable or disable v4 has a whole.
> The assumption is that if enabled, all minor versions that the kernel
> supports will be enabled by default.
> vers4.x allows individual minor versions to be disabled, so
>  vers4=yes
>  vers4.0=no
> would disable v4.0, just like "-V4 -N4.0"
I see...

> 
> I do wonder if this is ever valid though.  Why do we allow minor
> versions to be enabled/disabled?
IDK... I think Trond did this... you know...
when in doubt... blame Trond! 8-) 
 
> Does it make any sense to enable a non-contiguous set of minor versions?
I don't think so... Talk about handing people rope! ;-)

> Should we just have a maximum NFSv4 minor version?
Maybe.. 

> 
> I was trying to duplicate the current functionality as closely as
> convenient.  That might not be best in this case.
You did a good job... this is definitely a nit.

steved.

