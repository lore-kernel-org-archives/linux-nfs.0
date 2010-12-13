From: Tim Watts <t.watts-AQ/gCgVxFfnQzY9nttDBhA@public.gmane.org>
Subject: Re: NooB Assitance with debugging NFSv4 client requested
Date: Mon, 13 Dec 2010 10:22:26 +0000
Message-ID: <4D05F3E2.6090902@imperial.ac.uk>
References: <4D024A8E.50407@imperial.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.cc.ic.ac.uk ([155.198.5.156]:56091 "EHLO
	smtp2.cc.ic.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab0LMKW3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 05:22:29 -0500
Received: from squidward.hep.ph.ic.ac.uk ([155.198.211.86])
	by smtp2.cc.ic.ac.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <t.watts-AQ/gCgVxFfnQzY9nttDBhA@public.gmane.org>)
	id 1PS5Y2-00040R-Pb
	for linux-nfs@vger.kernel.org; Mon, 13 Dec 2010 10:22:26 +0000
In-Reply-To: <4D024A8E.50407-AQ/gCgVxFfnQzY9nttDBhA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bump - anyone :)

Please note - I'm not requesting anyone fix a deeply obscure problem. 
I'm a sysadmin - I'd just be really grateful for some pointers to help 
me continue debugging this myself...

Ta,

Tim

On 10/12/10 15:43, Tim Watts wrote:
> Hi,
>
> I have an NFSv4 client set up on Ubuntu 10.04.1 LTS x86. The NFSv4
> server is running Centos 5.5 and we use MIT kerberos and LDAP for
> users/groups. This seems to work well with Centos 5.5 clients
>
> All works fine with my Ubuntu client, except after a while my client
> acts like it loses its authentication - symptom: home directory mount
> drops to "nobody" - I see the mount as "other" - no write access, can
> read files that have world read bit set etc.
>
> This can happen anytime between 48 hours and 2 hours after a full client
> reboot. It seems to be triggered by active use of thunderbird via the
> NFSv4 mounted home dir which suggests it may be load sensitive.
>
> When it happens, if I unmount my home dir (killing the desktop of
> course) , then remount the fault is cleared and I can work again.
>
> What doesn't work is just doing a kinit -f or restarting idmapd or gssd.
>
> I have run rpc.gssd in foreground debug mode and that doesn't say much
> during the problem times, ditto idmapd. We are using openldap for passwd
> and group lookups cached locally with nscd.
>
> I have tried upping kernel debugging:
>
> rpcdebug -m nfs -s vfs dircache lookupcache pagecache proc xdr file root
> callback client mount all
>
> but I'm not sure what I'm looking for.
>
> The symptoms feel like the kernel is losing the ticket or timing it out
> or possibly the ID mapping is failing - is there any way to examining
> the state of the kernel ticket cache or anything else I could be looking
> for?
>
> I am tempted to say this is a bug, possibly in the Ubuntu build, but I
> would like to investigate further.
>
> Any pointers much appreciated as to how I might isolate the fault further.
>
> Cheers
>
> Tim


-- 
Tim Watts
Linux Sysadmin, High Energy Physics, Imperial College London
Tel: 020 759 47809
