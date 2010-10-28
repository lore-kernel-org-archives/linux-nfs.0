Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0J1Tzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 15:55:53 -0400
Message-ID: <4CC9D543.4020004@RedHat.com>
Date: Thu, 28 Oct 2010 15:55:47 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/6] nfs(5): Document remount behavior
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net> <20101026155847.19184.44036.stgit@matisse.1015granger.net> <4CC9BAA8.5000509@RedHat.com> <BFCEEA71-05CB-4D4F-9ED8-64B140E20D2C@oracle.com>
In-Reply-To: <BFCEEA71-05CB-4D4F-9ED8-64B140E20D2C@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/28/2010 02:58 PM, Chuck Lever wrote:
> 
> On Oct 28, 2010, at 2:02 PM, Steve Dickson wrote:
> 
>> Chuck,
>>
>> I'm a bit concern about this patch.... 
>>
>> I'm asking myself who is going care how remounts update 
>> /etc/mtab and what mode is used.
> 
> Someone who has done a remount and found that it doesn't behave as they expect. 
> I've handled bug reports like this.  When customers want to see existing 
> documentation of strange behavior, it's pretty important to have something to
> point them to.  Documentation is the first thing I'm asked for by customers 
> and system engineers who encounter weird NFS behavior.
Documentation is great! I too get numerous requests for documentation.
That's why I think are the first 3 paragraphs in "THE REMOUNT OPTION"
is perfect! Well written and to the point... Its the rest of 
the section I don't think we needed... that's all... 
 
> 
>> I just thinking that type of info 
>> adds a lot verbiage that nobody really care about.
> 
> Don't you think that's a bit harsh and even disrespectful? 
By no means... whatsoever... I was just being honest...
maybe a bit too brutally... ;-) My apologies if it came 
off in that manner...  

> What criteria do you use to decide that "no-one cares"?
I can't image anybody caring about how the inners of /etc/mtab
are being maintained on an NFS umount... As long as the unmount
works, that's all they care about... 
> 
> This patch documents very confusing behavior that is not documented anywhere else.
> It's not documented elsewhere because other file systems don't have a dependency 
> on /etc/mtab as we have.  This also documents why replacing /etc/mtab with 
> /proc/mounts will cause some fuzzy NFS umount behavior (which is exactly the documentation you were looking for last week).
> 
> The fact that it took me so long to figure out is evidence enough that this is 
> not obvious and needs to be written down somewhere.  Where else should we document
> behavior that is related to /etc/fstab and mount(8), and is NFS specific?
How about the NFS FAQ? 

All I'm saying is that type of details information (how mtab is managed) is
not useful to a system admin trying figure out how to use remount 
on an NFS file system... So I think its a waste to put in the man page... 

> 
>> Plus why are
>> we documenting something (/etc/mtab) that will be going 
>> away as soon as humanly possible? 
> 
> Do you have a schedule for this?  I've talked very recently with Karel, 
> and libmount is not even ready to be published.  The work to integrate 
> libmount into every mount subcommand sounds like it could be a ways in 
> the future.  (Karel and I even discussed me doing this work for mount.nfs).
No I don't... but it can come soon enough... IMHO... 
Cool... Karel is a good guy to work with... 

> 
> I expect we will have a dependence on /etc/mtab for a while yet.  And, 
> it's pretty easy to change these docs once we've transitioned.
> 
>> Basically I'm saying the entire "Unmounting after a remount" 
>> section is not needed. Only the 3 paragraphs in "THE REMOUNT OPTION"
>> section are needed IMHO... 
> 
> 
> I'll consider recrafting it, but this is important and confusing 
> behavior that must be documented.  We can argue about how the information 
> is presented, but just throwing it all out and ignoring it is not an option.
> 
Good...

All I'm saying make the it concise and to the point so its useful
to a system admin... Like the first 3 paragraphs are... 

And maybe I'm wrong...  but... I just don't think an system admin 
really cares what happens to the mtab after a umount of a 
remounted mount point... As long as the unmount works... they are
happy... again... IMHO... 

steved.
