Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:54925 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754810Ab2EHQZI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 May 2012 12:25:08 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Tue, 08 May 2012 12:25:05 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Myklebust, Trond" <trond.myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: Another try at =?UTF-8?Q?LNFS=3F?=
In-Reply-To: <1336488394.5307.2.camel@lade.trondhjem.org>
References: <775e0a2cd5e2e4c8f52401214dbd9413@countercultured.net>
 <1333646141.4573.1.camel@lade.trondhjem.org>
 <85614613274dbfef5253665a84a36374@countercultured.net>
 <7193f15f28e7483021244c72ee285516@countercultured.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915A300@SACEXCMBX04-PRD.hq.netapp.com>
 <4FA8AE22.3000305@davequigley.com>
 <1336488394.5307.2.camel@lade.trondhjem.org>
Message-ID: <ddb5deaa88c1c43c695149b0c7d1c2cd@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/08/2012 10:46, Myklebust, Trond wrote:
> On Tue, 2012-05-08 at 01:24 -0400, Dave Quigley wrote:
>> On 4/5/2012 10:20 PM, Myklebust, Trond wrote:
>> >> -----Original Message-----
>> >> From: David Quigley [mailto:dpquigl@davequigley.com]
>> >> Sent: Thursday, April 05, 2012 2:38 PM
>> >> To: Myklebust, Trond
>> >> Cc: linux-nfs@vger.kernel.org
>> >> Subject: Re: Another try at LNFS?
>> >>
>> >> On 04/05/2012 17:26, David Quigley wrote:
>> >>> On 04/05/2012 13:15, Myklebust, Trond wrote:
>> >>>> On Thu, 2012-04-05 at 13:02 -0400, David Quigley wrote:
>> >>>>> Now that we're past the 3.4 merge window should I post the 
>> LNFS
>> >>>>> modifications for review for when 3.5 rolls around?
>> >>>>
>> >>>> The sooner the better. It looks as if there will be quite a bit 
>> of
>> >>>> stuff going into 3.5, so it would be nice to maximise our 
>> testing
>> >>>> window.
>> >>>>
>> >>>> Thanks!
>> >>>>    Trond
>> >>>
>> >>> I have a mostly working copy for 3.2 which I can forward port 
>> but I'm
>> >>> having an issue with it. The revalidate code changed at some 
>> point and
>> >>> just to get things working I dropped a piece of code from the 
>> patch
>> >>> set that I couldn't figure out how to transition to the new 
>> revalidate
>> >>> code. Unfortunately this is the initial get of the security 
>> label so
>> >>> the security label is invalid until the first cache 
>> invalidation. Any
>> >>> suggestions on where to place this code? I can give you the 
>> original
>> >>> code snippet when I get home that I dropped.
>> >>>
>> >>> Dave
>> >>> --
>> >>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-nfs"
>> >>> in
>> >>> the body of a message to majordomo@vger.kernel.org More 
>> majordomo
>> >> info
>> >>> at  http://vger.kernel.org/majordomo-info.html
>> >>
>> >> Looking at my patches it looks like nfs_lookup_revalidate was 
>> changed and at
>> >> the time I couldn't figure out what it was changed to.
>> >
>> > Hi Dave,
>> >    There shouldn't be much in the way of changes in 
>> nfs_lookup_revalidate(): I was just trying to clean it up in 
>> preparation for the atomic open patches that Miklos is currently 
>> working on.
>> > At this point, it looks as if most of that functionality will in 
>> any case be moved into the struct file_operations->open callback, so 
>> that we can keep ->d_revalidate() as a pure lookup function.
>> >
>> > Cheers
>> >    Trond
>>
>>
>> Ok I looked at the code again finally and I think I figured out the
>> problem. nfs_prime_dcache is new and there are a couple of calls in
>> there that should be taking a label that I just passed null to. We 
>> don't
>> store the nfs4_label in the inode so I'm not sure how to get the 
>> label
>> back for the nfs_refresh_inode call and then we have a call to 
>> nfs_fhget
>> which would normally get us label data. I think the nature of this
>> function is what I don't quite understand. When is it called? What I
>> think is happening is that I should be pulling the label data into 
>> the
>> inode in this function but I'm not because I'm passing nulls here. 
>> if I
>> figure out how to get real label data into the inode at this point I
>> should be able to fix the bug where we aren't getting labels until 
>> the
>> first cache invalidation.
>>
>> Dave
>
> nfs_prime_dcache is called after a READDIRPLUS operation. In the case 
> of
> NFSv4, that means that we request a filehandle and full file 
> attributes
> in our READDIR operation. We then use the results to create dentries
> that we then populate the dcache with:
> IOW: as far as the VFS is concerned, it looks as if we've done a 
> bunch
> of lookups of these files.

Does it seem like this might be the problem area though or am I barking 
up the wrong tree? I could look through my porting again and make sure I 
didn't miss anything but that would take a lot of time I don't have at 
the moment. I have a telecon tonight at 9pm with some people in Asia who 
want to help with development so I may have them look into this bug and 
try to take care of it. After that it should just be a forward port to 
3.5/3.6.

Dave
