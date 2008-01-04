From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 02:04:38 -0500
Message-ID: <477DDA86.6020100@garzik.org>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org> <477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54529 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbYADHEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 02:04:47 -0500
In-Reply-To: <477DD11B.40909-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks wrote:
> It's entirely possible someone might run your server code on a spare
> machine,
> given functioning install packages and easy instructions.

Easy enough to do...


>> Plus, surely in this day and age, we can figure out something better 
>> than waiting for face-to-face events to test something.  Maybe somebody 
>> could arrange a donation of some slice of a grid (Amazon EC2?), make 
>> various OS images available, and give engineers some way to request a 
>> selection of tests, with a selection of OS images?
>>   
> Vendors turn up to cthon with proprietary and unreleased software and
> hardware
> which they most certainly are not going to let anyone else run for
> them.  Also,
> being in the same hall with all those vendors' technical folks tends to
> make bugs
> shallow.  It's a very valuable exercise for any organisation making a
> living from
> NFS.

Certainly, but I could see a grid of released, non-proprietary software 
as quite a valuable resource in addition to f2f events.  Quality can 
only increase, if the [Linux | *BSD | OpenSolaris |...] NFS clients 
could run regression tests against several different NFS servers, each 
time an NFS client receives a set of changes.

Even if it's only the open source operating systems that wish to 
participate, having a mix of OS's and platforms would be useful.  A 
permanent, virtual cthon.


>> I really wish the entire wire protocol were scrapped and replaced with 
>> something more sane, and easier to parse. 
> You had me worried there for a moment, I thought you might be the first
> person to admit to liking the NFS4 protocol design.
> 
>> It's tempting to see what would arise from a clean-slate wire protocol 
>> effort, something that is otherwise compatible with NFS 4.x operations, 
>> objects, and data model.

It's more like v4 is a vast relative improvement over prior NFS.  Given 
the huge number of NFS users and sites, IMO v4 is a huge improvement for 
Unix file sharing overall.

But if you are dreaming of a truly clean slate protocol...  I've got a 
long wish list too :)


> Much like the old phone system, the primary value of protocols like NFS
> is the
> widespread presence of reliable conformant implementations.  Most of the
> rest of
> the NFS is problematic.  I would argue that some aspects of the NFS
> operations,
> objects, and data model is rather more busted than the XDR encoding.
> 
> The classic persistent file handles, for example, could be considered a
> major
> design flaw.  Firstly it makes the inode# -> dentry lookup a performance
> path
> for the underlying filesystem, which it isn't in any local load. 

Oh, certainly.  I was mainly thinking a replacement of the wire protocol 
would be an easier step for people to swallow than a new protocol.

But if you are implying there is enough momentum to simply rewrite NFS 
from scratch, I'll cheer and help out with coding :)  Or maybe Zach 
Brown will do it for us with CRFS: 
http://linux.conf.au/programme/detail?TalkID=247

A big feature of NFS today is its high Just Works(tm) value (ease of 
configuration and some minimum level of fault tolerance), so any 
replacement would need to have similar attributes.


> Another major flaw is putting the client in control of when unstable data is
> written to disk, but not providing any way for the client to find out how to
> do that optimally.
> 
> Then there's the NFS4 approach to extended attributes.

Ugh.  Don't get me started.  That's not in my server yet, but I can 
already see the mess ahead.

	Jeff




