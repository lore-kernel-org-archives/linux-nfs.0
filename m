From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 17:24:27 +1100
Message-ID: <477DD11B.40909@melbourne.sgi.com>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org> <477DC501.3060104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:56929 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753346AbYADGQ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2008 01:16:26 -0500
In-Reply-To: <477DC501.3060104@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Garzik wrote:
> J. Bruce Fields wrote:
>>
>> 	http://www.connectathon.org/
>>
>>     
> As this isn't an official RH project, I would probably have to pay my 
> own way, which makes it doubtful :)
>   

It's entirely possible someone might run your server code on a spare
machine,
given functioning install packages and easy instructions.
> Plus, surely in this day and age, we can figure out something better 
> than waiting for face-to-face events to test something.  Maybe somebody 
> could arrange a donation of some slice of a grid (Amazon EC2?), make 
> various OS images available, and give engineers some way to request a 
> selection of tests, with a selection of OS images?
>   
Vendors turn up to cthon with proprietary and unreleased software and
hardware
which they most certainly are not going to let anyone else run for
them.  Also,
being in the same hall with all those vendors' technical folks tends to
make bugs
shallow.  It's a very valuable exercise for any organisation making a
living from
NFS.

> I really wish the entire wire protocol were scrapped and replaced with 
> something more sane, and easier to parse. 
You had me worried there for a moment, I thought you might be the first
person to admit to liking the NFS4 protocol design.

> It's tempting to see what would arise from a clean-slate wire protocol 
> effort, something that is otherwise compatible with NFS 4.x operations, 
> objects, and data model.
>   

Much like the old phone system, the primary value of protocols like NFS
is the
widespread presence of reliable conformant implementations.  Most of the
rest of
the NFS is problematic.  I would argue that some aspects of the NFS
operations,
objects, and data model is rather more busted than the XDR encoding.

The classic persistent file handles, for example, could be considered a
major
design flaw.  Firstly it makes the inode# -> dentry lookup a performance
path
for the underlying filesystem, which it isn't in any local load. 
Secondly, it's
inherently insecure if you export anything less than an entire
filesystem, unless
you use a slow, buggy, and non-conformant hack like subtree_check.

Another major flaw is putting the client in control of when unstable data is
written to disk, but not providing any way for the client to find out how to
do that optimally.

Then there's the NFS4 approach to extended attributes.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

