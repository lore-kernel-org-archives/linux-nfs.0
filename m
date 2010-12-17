From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NooB Assitance with debugging NFSv4 client requested
Date: Fri, 17 Dec 2010 14:16:39 -0500
Message-ID: <20101217191639.GB14510@fieldses.org>
References: <4D024A8E.50407@imperial.ac.uk>
 <4D0A8CC9.9050306@imperial.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tim Watts <t.watts-AQ/gCgVxFfnQzY9nttDBhA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720Ab0LQTQk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 14:16:40 -0500
In-Reply-To: <4D0A8CC9.9050306-AQ/gCgVxFfnQzY9nttDBhA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:03:53PM +0000, Tim Watts wrote:
> On 10/12/10 15:43, Tim Watts wrote:
> >Hi,
> >
> >I have an NFSv4 client set up on Ubuntu 10.04.1 LTS x86. The NFSv4
> >server is running Centos 5.5 and we use MIT kerberos and LDAP for
> >users/groups. This seems to work well with Centos 5.5 clients
> >
> >All works fine with my Ubuntu client, except after a while my client
> >acts like it loses its authentication - symptom: home directory mount
> >drops to "nobody" - I see the mount as "other" - no write access, can
> >read files that have world read bit set etc.
> >
> >This can happen anytime between 48 hours and 2 hours after a full client
> >reboot. It seems to be triggered by active use of thunderbird via the
> >NFSv4 mounted home dir which suggests it may be load sensitive.
> >
> >When it happens, if I unmount my home dir (killing the desktop of
> >course) , then remount the fault is cleared and I can work again.
> >
> >What doesn't work is just doing a kinit -f or restarting idmapd or gssd.
> >
> >I have run rpc.gssd in foreground debug mode and that doesn't say much
> >during the problem times, ditto idmapd. We are using openldap for passwd
> >and group lookups cached locally with nscd.
> >
> >I have tried upping kernel debugging:
> >
> >rpcdebug -m nfs -s vfs dircache lookupcache pagecache proc xdr file root
> >callback client mount all
> >
> >but I'm not sure what I'm looking for.
> >
> >The symptoms feel like the kernel is losing the ticket or timing it out
> >or possibly the ID mapping is failing - is there any way to examining
> >the state of the kernel ticket cache or anything else I could be looking
> >for?
> >
> >I am tempted to say this is a bug, possibly in the Ubuntu build, but I
> >would like to investigate further.
> >
> >Any pointers much appreciated as to how I might isolate the fault further.
> >
> >Cheers
> >
> >Tim
> 
> Right - thanks for all the discussions...
> 
> The security (krb tickets) seem stable now I have renamed my root
> principle cache file to /tmp/kerberos5cc_tjw_root rather than
> /tmp/krb5cc_myuid_root
> 
> idmap seems still unstable - often my file groups go to nobody
> despite my file owners being correct.
> 
> Our LDAP server setup is new (replaced NIS) and we see sometimes
> that other servers (eg the mailserver) occasionally don't get an
> LDAP query through in a timely manner once in a blue moon.
> 
> I would like to see idmapd try a bit harder and/or not cache
> bad/missing answers for so long but I think that is roughly where
> the other problem lies - thus is debuggable and soluable.

Let us know what you figure out.

--b.
