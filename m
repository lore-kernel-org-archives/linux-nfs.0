Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp2.uvm.edu ([132.198.101.169]:38961 "EHLO smtp2.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898AbaCXVDc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Mar 2014 17:03:32 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
From: Benjamin Coddington <bcodding@uvm.edu>
In-Reply-To: <53308CD4.9020307@RedHat.com>
Date: Mon, 24 Mar 2014 17:03:26 -0400
Cc: linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Message-Id: <B126AD05-73BE-4395-BFED-F05B67856EAA@uvm.edu>
References: <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 24, 2014, at 3:51 PM, Steve Dickson <SteveD@redhat.com> wrote:

>>> Finally, what -n value do plan on using? Maybe a blurb in the man page
>>> on what a good number is and why....
>> 
>> I've got this running now with -n160, since 
>> we have ~60K distinct uid/gid s.  Ideally, I'd like to re-submit 
>> this to self-scale which wouldn't require any sysadmin tuning, 
>> but I haven't had the time.  Really, this is just a quick fix 
>> for the brokenness that's in current RHEL and less-new Fedora.
> The brokenness in RHEL will be healing very soon... See 
> https://bugzilla.redhat.com/show_bug.cgi?id=1033708. RHEL is 
> basically going back to using rpc.idmapd on the client and
> nfsidmap is going away... It as just a bad dream... It never
> happen! ;-)

This BZ says the fix is coming in nfs-utils by removing the nfsidmap command.  But IIRC, unless the kernel side of the idmapper is changed, it will exec request-key for every lookup before falling back to the upcall, and there's no cache in front of that.  Isn't that going to have some performance problems?  I'm much more interested in getting the keyrings to work, since they seem to offer significant performance gains.

If RH is going to change the kernel side of the idmapper to only upcall, then I'd be satisfied to use that.

Ben