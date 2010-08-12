From: Andy Adamson <andros@netapp.com>
Subject: Re: numeric UIDs
Date: Thu, 12 Aug 2010 09:20:34 -0400
Message-ID: <54C2C4FC-67FA-4E49-B252-A9E73027F6AF@netapp.com>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org> <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org> <1280887336.24669.23.camel@heimdal.trondhjem.org> <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu> <C2AFF31B-A4A4-432C-A152-B28676B8C3A4@netapp.com> <03068BD0-0613-469E-B918-07019EC54055@u.washington.edu> <20100812090602.3a24c2bd@notabene>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: David Brodbeck <brodbd@u.washington.edu>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61857 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759847Ab0HLNUi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2010 09:20:38 -0400
In-Reply-To: <20100812090602.3a24c2bd@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 11, 2010, at 7:06 PM, Neil Brown wrote:

> On Wed, 4 Aug 2010 14:32:06 -0700
> David Brodbeck <brodbd@u.washington.edu> wrote:
> 
>> 
>> On Aug 4, 2010, at 11:30 AM, Andy Adamson wrote:
>> 
>>> 
>>> On Aug 4, 2010, at 1:06 PM, David Brodbeck wrote:
>>> 
>>>> 
>>>> On Aug 3, 2010, at 7:02 PM, Trond Myklebust wrote:
>>>> 
>>>>> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
>>>>>> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
>>>>>>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
>>>>>>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
>>>>>> 
>>>>>>> 2) Why is AUTH_SYS so sacrosanct?
>>>>>> 
>>>>>> Because it's what almost everyone uses.
>>>>> 
>>>>> No. It's the _default_. ...and a really really bad default.
>>>> 
>>>> The problem is the only supported alternative is to set up Kerberos.  This is a lot of work, especially for established sites where it essentially requires every user to change their password during the migration.  It also creates problems with ticket expiration if you have daemons or batch jobs that need continuous access to NFS filesystems.
>>> 
>>> Changing passwords is a good thing - should be done on a regular basis anyway.
>> 
>> True, 
> 
> Not true.  Forced password changing encourages poor choice of passwords and
> other poor practices.

This is not rocket science. Picking a good password is easy, once you know how to do it - after all, it's not like there's a shortage of good passwords!

> Much better to choose a really good password and only change it when you have
> reason to believe that it has been compromised,

well, then of course it's too late  :)

> or when you get bored of the
> old one.
> 
> (better still is two-factor authentication of course).
> 
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

