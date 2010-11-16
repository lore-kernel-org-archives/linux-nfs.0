Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:38315 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab0KPQJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 11:09:21 -0500
Message-ID: <4CE2AA3B.6070302@openoffice.nl>
Date: Tue, 16 Nov 2010 16:58:51 +0100
From: Valentijn Sessink <v.sessink@openoffice.nl>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
In-Reply-To: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Chuck,

We have been disabling NM for years now because of this. As far as I can
see from it's behaviour, it sets the hostname all by itself, during
startup (but I could be wrong here, didn't look in the source code).

V.

Chuck Lever schreef:
>  ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS failure.  Minor code may provide more information - Key table entry not found
>  unable to obtain root (machine) credentials
>  do you have a keytab entry for nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab?
[...]
> Removing "your.host	your" from the "::1" entry makes this problem go away -- rpc.svcgssd starts up as expected.
> 
> Now I reboot, and NetworkManager happily adds "your.host	your" back to the "::1" entry, and rpc.svcgssd fails again.  I haven't tried this, but I suspect if the ::1 entry weren't there, NM would add "your.host.net	your" to the IPv4 loopback entry, and we'd have the same problem.
-- 
http://www.openoffice.nl/   Open Office - Linux Office Solutions
Valentijn Sessink  v.sessink@openoffice.nl  +31(0)20-4214059
