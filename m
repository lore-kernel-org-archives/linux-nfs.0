Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:47460 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965614Ab2B1Pub convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 10:50:31 -0500
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can cause silent data corruption."
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com>
Date: Tue, 28 Feb 2012 10:50:19 -0500
Cc: Jeff Layton <jlayton@redhat.com>, Jim Rees <rees@umich.edu>,
        Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7C4B183F-8357-4D08-B30A-73196954A5D4@oracle.com>
References: <1330406521.9157.16.camel@serendib> <20120228065218.7e110936@tlielax.poochiereds.net> <20120228124646.GA2528@umich.edu> <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com>
To: Harshula Jayasuriya <harshula@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 28, 2012, at 9:35 AM, Chuck Lever wrote:

> 
> On Feb 28, 2012, at 7:46 AM, Jim Rees wrote:
> 
>> Jeff Layton wrote:
>> 
>> On Tue, 28 Feb 2012 16:22:01 +1100
>> Harshula <harshula@redhat.com> wrote:
>> 
>>> Hi Steve,
>>> 
>>> The following openSUSE nfs-utils patch, warn-nfs-udp.patch, is not
>>> included upstream:
>>> 
>>> https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb
>>> 
>>> Please consider including it.
>>> 
>>> Thanks,
>>> #
>>> 
>> 
>> I think that patch looks reasonable and clearly documenting the
>> problems with UDP is a wonderful thing.
>> 
>> It may be best to send it formally to steved and the list as a real
>> [PATCH] with a real description and SoB line.
>> 
>> This feels like the wrong place to document this, since it affects anything
>> that uses udp, not just nfs.
> 
> NFS has a particular sensitivity to unreliable datagram transports, and that is a well-known problem.  NetApp's retired TR-3183 and many Oracle meta documents mention the problems with NFS over UDP.  Most other uses of UDP do not involve such large datagrams.
> 
> My comment is that if the text in the TRANSPORT METHODS section in nfs(5) about UDP reassembly is not adequate it should be updated.  I would rather see the meat of the proposed text merged into that section; otherwise we have two disparate sections discussing the same topic.  That section is where this kind of discussion belongs.

A few more comments.

Any file, including a /proc file, called out in new text should be added to the FILES section, IMO.

If we can't resolve the provenance issue, someone could rewrite the patch from scratch so that it addresses the review comments.

I don't agree with adding in-code warnings.  Mount works silently unless it fails, and this is not a mount failure.  Would such warnings ever be seen for NFS mounts added to /etc/fstab, or performed by automounter?  I think by and large most people type "mount -t nfs" without options and will get our current default transport setting, which is TCP, or UDP if the server does not support TCP.  Isn't that adequate?

We also know that the risk of using UDP is mitigated by using jumbo frames, specifying a small r/wsize, or by reducing the fragment reassembly timeout.  If an admin does those things, she still gets the warning.

It seems needlessly alarmist, and useless for our most common use cases.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




