Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.cc.ic.ac.uk ([155.198.5.156]:48235 "EHLO
	smtp2.cc.ic.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756277Ab0LPWD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 17:03:57 -0500
Received: from warpfield01.dionic.net ([81.2.78.46] helo=[10.0.1.55])
	by smtp2.cc.ic.ac.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <t.watts@imperial.ac.uk>)
	id 1PTLvW-0003Pn-Jh
	for linux-nfs@vger.kernel.org; Thu, 16 Dec 2010 22:03:54 +0000
Message-ID: <4D0A8CC9.9050306@imperial.ac.uk>
Date: Thu, 16 Dec 2010 22:03:53 +0000
From: Tim Watts <t.watts@imperial.ac.uk>
To: linux-nfs@vger.kernel.org
Subject: Re: NooB Assitance with debugging NFSv4 client requested
References: <4D024A8E.50407@imperial.ac.uk>
In-Reply-To: <4D024A8E.50407@imperial.ac.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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

Right - thanks for all the discussions...

The security (krb tickets) seem stable now I have renamed my root 
principle cache file to /tmp/kerberos5cc_tjw_root rather than 
/tmp/krb5cc_myuid_root

idmap seems still unstable - often my file groups go to nobody despite 
my file owners being correct.

Our LDAP server setup is new (replaced NIS) and we see sometimes that 
other servers (eg the mailserver) occasionally don't get an LDAP query 
through in a timely manner once in a blue moon.

I would like to see idmapd try a bit harder and/or not cache bad/missing 
answers for so long but I think that is roughly where the other problem 
lies - thus is debuggable and soluable.

Thanks for the help guys!

Cheers

Tim

-- 

Tim Watts
Linux Sysadmin, High Energy Physics, Imperial College London
Tel: 020 759 47809
