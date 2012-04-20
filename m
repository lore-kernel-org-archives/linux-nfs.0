Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:21211 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab2DTUpR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 16:45:17 -0400
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1334952788.3295.24.camel@lade.trondhjem.org>
Date: Fri, 20 Apr 2012 16:14:29 -0400
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>, Jim Rees <rees@umich.edu>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Message-Id: <1C008FE1-241B-42CD-8916-079CCF2A0E72@oracle.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com> <20120420194504.GA10259@umich.edu> <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com> <1334952788.3295.24.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 20, 2012, at 4:13 PM, Myklebust, Trond wrote:

> On Fri, 2012-04-20 at 19:57 +0000, Adamson, Dros wrote:
>> On Apr 20, 2012, at 3:45 PM, Jim Rees wrote:
>> 
>>> Weston Andros Adamson wrote:
>>> 
>>> nfs4_path() was parsing the path component by splitting on the first colon.
>>> This is wrong when an IPv6 address is used to mount a server.
>>> 
>>> For example, having mounted 'fc00::10:/export', nfs4_path() returned
>>> ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) to fail
>>> in nfs4_validate_fspath().
>>> 
>>> Parsing the path component by using the *last* colon works with
>>> IPv6 as well as IPv4 addrs.
>>> 
>>> What if your mount is:
>>> 
>>> server.edu:/export/:I-like-colons:
>>> 
>>> It seems to me something has to give.  Either we require v6 addresses be
>>> enclosed in [], export dirs start with "/", or exports have no ":".
>> 
>> 
>> Yeah, you're right.
>> 
>> Although IPv6 addrs must be enclosed in [] to work with mount, it's always displayed in the kernel without the [].
>> 
>> I suppose the correct fix is to always display IPv6 addresses enclosed in [], which might touch a *lot* of places.
>> 
>> Thoughts?  I'll wait for others to chime in before I go fixing this. I have a set of nfsd and mountd patches that deal with similar issues on the server side.  I'll clean those up and submit them before getting back to this.
> 
> We do know which part is the hostname, and which is the pathname. If you
> look at "try_location()", you'll see that the hostname is stored in
> location->servers, and is then copied into this empty buffer.
> 
> If you want to test if that is an IPv6 address so that you can enclose
> it in [], then that should be fairly easy to do right there...

Yes, that's kind of what was I was thinking.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




