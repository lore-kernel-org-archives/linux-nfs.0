Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940AbcCGQAb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2016 11:00:31 -0500
Date: Mon, 7 Mar 2016 11:00:28 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Mark Valites <mvalites@buffalo.edu>
cc: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes
In-Reply-To: <56DDA2C2.3010806@buffalo.edu>
Message-ID: <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org>
References: <56DDA2C2.3010806@buffalo.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 7 Mar 2016, Mark Valites wrote:

> I recently updated a Red Hat 7 host. After rebooting, the nfs mounts on it
> (nfsver3,sec=krb5) failed to mount, due to the gss daemon segfaulting when the
> mount attempt happened:
>
> [    7.816487] FS-Cache: Loaded
> [    7.887575] FS-Cache: Netfs 'nfs' registered for caching
> [    7.931164] rpc.gssd[498]: segfault at 5544452e ip 00007fbc9d704ee6 sp
> 00007ffc37291678 error 4 in libc-2.17.so[7fbc9d5ca000+1b
> 4000]
> [    7.964578] abrt-hook-ccpp[994]: segfault at 0 ip 00007fba2e09431b sp
> 00007ffefa92fb50 error 4 in libreport.so.0.0.1[7fba2e0860
> 00+25000]
> [    7.965398] Process 994(abrt-hook-ccpp) has RLIMIT_CORE set to 1
> [    7.965483] Aborting core
>
> At mount time, The console displays these messages as well:
>
> RPC: AUTH_GSS  upcall timed out.
> Please check user daemon is running.
>
> gssd will start without issue if started manually on its own, but dies if I
> subsequently try to manually mount any of the nfs mounts.
>
> I've isolated the issue down to the latest update in the nfs-utils package:
>
> Working: nfs-utils-1.3.0-0.21.el7.x86_64
> Broken: nfs-utils-1.3.0-0.21.el7_2.x86_64
>
> (note the '_v2' difference)
>
> gssd/the mounting works without issue after backing down to the older
> nfs-utils version.
>
> It looks similar to the following bug report (fixed in 1.3.1), but I'm not
> 100% convinced it's the same:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1108615
>
> If this is in fact the issue, I would be happy keeping the updated nfs-utils
> version, but working around the issue via changing my krb5.conf, but I'm not
> sure where the *preferred*_realm comes from - I do have *default*_realm set in
> my krb5.conf.
>
> If that's not it, I'd be happy to provide any additional information that may
> assist in troubleshooting & welcome any suggestions, but I'd greatly prefer to
> retain the OS-supplied nfs-utils.
>
> -Mark

Hey Mark, could it be this one?

https://bugzilla.redhat.com/show_bug.cgi?id=1313090

Ben
