Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57584 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab0LMSzP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 13:55:15 -0500
Date: Mon, 13 Dec 2010 13:55:14 -0500
To: Tim Watts <t.watts@imperial.ac.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NooB Assitance with debugging NFSv4 client requested
Message-ID: <20101213185514.GA2230@fieldses.org>
References: <4D024A8E.50407@imperial.ac.uk>
 <4D05F3E2.6090902@imperial.ac.uk>
 <4D0606D0.4010702@imperial.ac.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D0606D0.4010702@imperial.ac.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 13, 2010 at 11:43:12AM +0000, Tim Watts wrote:
> Hmm,
> 
> Wonder if this is a clue (not noticed this before, but running
> idmapd in the foreground, it just whined):
> 
> rpc.idmapd: nfscb: read(/var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap): No
> such file or directory
> 
> (Repeated several times).
> 
> I'm veering towards this issue being an idmap problem.

All permissions are enforced on the server side--the effect of an
idmapper failure should just be that "ls -l" shows bad results (e.g.,
"nobody" as the owner of every file) and that commands like "chown"
fail.

If you're actually being prevented from performing normal filesystem
operations, then the most likely culprit is with gssd and krb5.

Might be worth filing a bug with ubuntu.

rpc.gssd debugging you've tried.  Sniffing client/server and client/kdc
traffic with wireshark might also show some more information.

I dunno.  Maybe strace rpc.gssd during the failure?

--b.

> 
> Cheers
> 
> tim
> 
> On 13/12/10 10:22, Tim Watts wrote:
> >Bump - anyone :)
> >
> >Please note - I'm not requesting anyone fix a deeply obscure problem.
> >I'm a sysadmin - I'd just be really grateful for some pointers to help
> >me continue debugging this myself...
> >
> >Ta,
> >
> >Tim
> >
> >On 10/12/10 15:43, Tim Watts wrote:
> >>Hi,
> >>
> >>I have an NFSv4 client set up on Ubuntu 10.04.1 LTS x86. The NFSv4
> >>server is running Centos 5.5 and we use MIT kerberos and LDAP for
> >>users/groups. This seems to work well with Centos 5.5 clients
> >>
> >>All works fine with my Ubuntu client, except after a while my client
> >>acts like it loses its authentication - symptom: home directory mount
> >>drops to "nobody" - I see the mount as "other" - no write access, can
> >>read files that have world read bit set etc.
> >>
> >>This can happen anytime between 48 hours and 2 hours after a full client
> >>reboot. It seems to be triggered by active use of thunderbird via the
> >>NFSv4 mounted home dir which suggests it may be load sensitive.
> >>
> >>When it happens, if I unmount my home dir (killing the desktop of
> >>course) , then remount the fault is cleared and I can work again.
> >>
> >>What doesn't work is just doing a kinit -f or restarting idmapd or gssd.
> >>
> >>I have run rpc.gssd in foreground debug mode and that doesn't say much
> >>during the problem times, ditto idmapd. We are using openldap for passwd
> >>and group lookups cached locally with nscd.
> >>
> >>I have tried upping kernel debugging:
> >>
> >>rpcdebug -m nfs -s vfs dircache lookupcache pagecache proc xdr file root
> >>callback client mount all
> >>
> >>but I'm not sure what I'm looking for.
> >>
> >>The symptoms feel like the kernel is losing the ticket or timing it out
> >>or possibly the ID mapping is failing - is there any way to examining
> >>the state of the kernel ticket cache or anything else I could be looking
> >>for?
> >>
> >>I am tempted to say this is a bug, possibly in the Ubuntu build, but I
> >>would like to investigate further.
> >>
> >>Any pointers much appreciated as to how I might isolate the fault
> >>further.
> >>
> >>Cheers
> >>
> >>Tim
> >
> >
> 
> 
> -- 
> Tim Watts
> Linux Sysadmin, High Energy Physics, Imperial College London
> Tel: 020 759 47809
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
