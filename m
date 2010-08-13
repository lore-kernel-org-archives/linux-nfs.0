From: Steve Dickson <SteveD@redhat.com>
Subject: Re: numeric UIDs
Date: Fri, 13 Aug 2010 10:40:18 -0400
Message-ID: <4C655952.4000103@RedHat.com>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org> <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761664Ab0HMOke (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 10:40:34 -0400
In-Reply-To: <20100803224245.GB9752@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/03/2010 06:42 PM, J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
>>>> On Tue, 2010-08-03 at 17:57 -0400, Jim Rees wrote:
>>>>> Daniel.Muntz@emc.com wrote:
>>>>>
>>>>>   I'll fourth this motion.  The spec goes out of its way to declare this a
>>>>>   violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a
>>>>>   uid string consisting of [0-9]+ be interpreted as the string
>>>>>   representation of a numeric UID--just as valid as a "user@domain" string.
>>>>>
>>>>> I argued for this as an option in the early days but was shouted down.
>>>>> Sorry I can't remember the details, it was many years ago.
>>>>
>>>> Why is nobody talking about fixing AUTH_SYS? The alternative to using
>>>> numeric uids/gids in NFS would be to use user@domain/group@domain in the
>>>> credential.
>>>
>>> I'm not sure what that does to address complaints like original
>>> poster's:
>>>
>>> 	http://marc.info/?l=linux-nfs&m=128080127215350&w=2
>>>
>>> And I'd like it to be possible to make the NFSv3->NFSv4 upgrade as
>>> transparent as possible.
>>
>> 1) RFC3530 does allow a workaround for cases where the _server_ doesn't
>> have a mapping from uid/gid -> name. We just haven't implemented it on
>> Linux servers (or clients).
> 
> Yeah, somebody should.

I'm assuming you are talking about in the about page 47, third
paragraph that starts with "To provide a greater degree of compatibility..."
or are you referring to a different part of the RFC?


steved.
