Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:47662 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756810Ab2DFNN2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2012 09:13:28 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 06 Apr 2012 09:13:26 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Myklebust, Trond" <trond.myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: RE: Another try at =?UTF-8?Q?LNFS=3F?=
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915A300@SACEXCMBX04-PRD.hq.netapp.com>
References: <775e0a2cd5e2e4c8f52401214dbd9413@countercultured.net>
 <1333646141.4573.1.camel@lade.trondhjem.org>
 <85614613274dbfef5253665a84a36374@countercultured.net>
 <7193f15f28e7483021244c72ee285516@countercultured.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915A300@SACEXCMBX04-PRD.hq.netapp.com>
Message-ID: <52582eccd514b86a8f3c178c948bfd69@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/05/2012 22:20, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: David Quigley [mailto:dpquigl@davequigley.com]
>> Sent: Thursday, April 05, 2012 2:38 PM
>> To: Myklebust, Trond
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: Another try at LNFS?
>>
>> On 04/05/2012 17:26, David Quigley wrote:
>> > On 04/05/2012 13:15, Myklebust, Trond wrote:
>> >> On Thu, 2012-04-05 at 13:02 -0400, David Quigley wrote:
>> >>> Now that we're past the 3.4 merge window should I post the LNFS
>> >>> modifications for review for when 3.5 rolls around?
>> >>
>> >> The sooner the better. It looks as if there will be quite a bit 
>> of
>> >> stuff going into 3.5, so it would be nice to maximise our testing
>> >> window.
>> >>
>> >> Thanks!
>> >>   Trond
>> >
>> > I have a mostly working copy for 3.2 which I can forward port but 
>> I'm
>> > having an issue with it. The revalidate code changed at some point 
>> and
>> > just to get things working I dropped a piece of code from the 
>> patch
>> > set that I couldn't figure out how to transition to the new 
>> revalidate
>> > code. Unfortunately this is the initial get of the security label 
>> so
>> > the security label is invalid until the first cache invalidation. 
>> Any
>> > suggestions on where to place this code? I can give you the 
>> original
>> > code snippet when I get home that I dropped.
>> >
>> > Dave
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe 
>> linux-nfs"
>> > in
>> > the body of a message to majordomo@vger.kernel.org More majordomo
>> info
>> > at  http://vger.kernel.org/majordomo-info.html
>>
>> Looking at my patches it looks like nfs_lookup_revalidate was 
>> changed and at
>> the time I couldn't figure out what it was changed to.
>
> Hi Dave,
>   There shouldn't be much in the way of changes in
> nfs_lookup_revalidate(): I was just trying to clean it up in
> preparation for the atomic open patches that Miklos is currently
> working on.
> At this point, it looks as if most of that functionality will in any
> case be moved into the struct file_operations->open callback, so that
> we can keep ->d_revalidate() as a pure lookup function.
>
> Cheers
>   Trond

Ok, I'll try to take a look at it next week since I head out of town 
for the weekend starting this afternoon. If I run into any other 
problems I'll check back with you guys. After that forward porting 
shouldn't be much of an issue its just time consuming and unfortunately 
my time is limited as of late.
