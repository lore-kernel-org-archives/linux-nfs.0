Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:35238 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964828Ab2CEPI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 10:08:59 -0500
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can cause silent data corruption."
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1330913825.9157.61.camel@serendib>
Date: Mon, 5 Mar 2012 10:08:46 -0500
Cc: Jeff Layton <jlayton@redhat.com>, Jim Rees <rees@umich.edu>,
        Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2194470C-5FD9-4317-9A30-2E6C244138D5@oracle.com>
References: <1330406521.9157.16.camel@serendib> <20120228065218.7e110936@tlielax.poochiereds.net> <20120228124646.GA2528@umich.edu> <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com> <7C4B183F-8357-4D08-B30A-73196954A5D4@oracle.com> <1330913825.9157.61.camel@serendib>
To: Harshula <harshula@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 4, 2012, at 9:17 PM, Harshula wrote:

> On Tue, 2012-02-28 at 10:50 -0500, Chuck Lever wrote:
>> On Feb 28, 2012, at 9:35 AM, Chuck Lever wrote:
> 
>>> My comment is that if the text in the TRANSPORT METHODS section in
>> nfs(5) about UDP reassembly is not adequate it should be updated.  I
>> would rather see the meat of the proposed text merged into that
>> section; otherwise we have two disparate sections discussing the same
>> topic.  That section is where this kind of discussion belongs.
> 
> Good point. I'll try to massage the text into that section.

Thanks.

>> A few more comments.
>> 
>> Any file, including a /proc file, called out in new text should be
>> added to the FILES section, IMO.
>> 
>> If we can't resolve the provenance issue, someone could rewrite the
>> patch from scratch so that it addresses the review comments.
> 
> We now know who authored (Olaf Kirch) and committed (Mads Martin
> Joergensen) the text at SUSE. Do we need to get a sign-off from someone
> at SUSE?

IMO if Olaf is still there, he can send a SOB.  But IANAL.

>> I don't agree with adding in-code warnings.  Mount works silently
>> unless it fails, and this is not a mount failure.  Would such warnings
>> ever be seen for NFS mounts added to /etc/fstab, or performed by
>> automounter?  I think by and large most people type "mount -t nfs"
>> without options and will get our current default transport setting,
>> which is TCP, or UDP if the server does not support TCP.  Isn't that
>> adequate?
>> 
>> We also know that the risk of using UDP is mitigated by using jumbo
>> frames, specifying a small r/wsize, or by reducing the fragment
>> reassembly timeout.  If an admin does those things, she still gets the
>> warning.
>> 
>> It seems needlessly alarmist, and useless for our most common use
>> cases.
> 
> Sounds reasonable. Just the man page text then.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




