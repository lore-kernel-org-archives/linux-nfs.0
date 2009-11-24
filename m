From: Peter Staubach <staubach@redhat.com>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 16:19:32 -0500
Message-ID: <4B0C4DE4.1090008@redhat.com>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com> <20091124205616.GB29856@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933754AbZKXVTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 16:19:35 -0500
In-Reply-To: <20091124205616.GB29856@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Nov 24, 2009 at 09:29:47AM -0500, Steve Dickson wrote:
>>
>> On 11/23/2009 06:32 PM, Neil Brown wrote:
>>> Hi,
>>>  I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
>>>  got a bug report - "-o nfsvers=3" was needed to mount NFSv3
>>>  filesystems.
>>>
>>>  mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
>>>  if it gets ENOENT.  This works fine.
>>>  However for kernel prior to 2.6.25, you don't get ENOENT, you get
>>>  EPERM.
>>>  In that case the fall-back to v3 doesn't happen and you get a failure
>>>  to mount.
>>>
>>>  So I think we need to fall back on EPERM as well.  See below.
>> I already posted this patch on the v4 mailing list
>> http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
>> but it got shot down...  at least that's how I interpreted the
>> responses... 
>>
>> But I do thing we need this, since there are so many server 
>> that will simple break if we don't... Agreed?
> 
> My position is that servers should either a) turn off NFSv4 or b) add a
> pseudoroot, and that we should modify initscripts to make this harder to
> screw up.
> 
> (For now (without automatic pseudoroot creation) we should by default be
> running rpc.nfsd with -N 4; and adding the v4 support should be
> something administrators do when they add a pseudoroot.)
> 
> ((If this is really totally unfeasible, then I should quickly cue up a
> revert for the patch I have queued for 2.6.33 which changes this error
> again, to SERVERFAULT....))
> 

None helps new client systems who are forced to deal with older
server deployments.  It is a bad thing to force customers to change
old servers simply because they want to deploy new clients.  New
systems are generally just supposed to fit into existing networks
and not have to mold those networks to fit the new client's view
of the world.

Is this such a bad patch, to account for our own short sightedness
when designing the original NFSv4 server implementation?  It is
even at the user level and not in the kernel...

	Thanx...

		ps
