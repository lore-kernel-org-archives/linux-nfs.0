Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:39121 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab0KQQPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 11:15:14 -0500
Message-ID: <4CE3FF8B.9070408@blub.net>
Date: Wed, 17 Nov 2010 17:15:07 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>	<4CE2AA3B.6070302@openoffice.nl>	<4CE2DF2D.9070603@blub.net>	<20101116201753.GB4482@merit.edu>	<577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com>	<20101116205436.GA4595@merit.edu>	<44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com>	<4CE3F249.8050301@RedHat.com>	<C2312B32-B190-41C4-A4C8-C29231DBA305@oracle.com> <AANLkTinJyFHom5JQg5s+yX+6NRBw01S6a9gbwtk5WaLB@mail.gmail.com>
In-Reply-To: <AANLkTinJyFHom5JQg5s+yX+6NRBw01S6a9gbwtk5WaLB@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kevin Coffman schreef:
> This issue affects gss authentication in sshd as well.

"The issue" being that "gethostname()" returns nonsense after
NetworkManager configures the nonsense with "sethostname()".

I looked at the source code of Networkmanager, briefly, and it does look
like they do their utter best to make the hostname anything that you did
not want it to be, they first look in "system-settings" - but I can't
see what that is, then they use "automatic hostname from DHCP, VPN
etc.", only then to fall back to "the original hostname when NM
started". But the "set_system_hostname()" function has
"FALLBACK_HOSTNAME" (being localhost.localdomain) all over the place, so
 a single call to set_system_hostname with the wrong settings will mess
things up for the rest of the uptime of the machine.

>  I believe this
> is all the way down in the Kerberos code, which has been this way for
> years.  I'm not sure what needs to be changed to "get it right".

If something messes with "sethostname()", you can be sure that
"gethostname()" will return the mess.

Apart from that, IIRC, there was some discussion about the "Domain"
clause in the idmapd.conf and if that should come from the KRB domain
settings; problem with that, again IIRC, is, that then the idmapper
would become dependent on kerberos libraries.


If you'll ask me, I don't think there's such a big problem. The only
problem is that NetworkManager shouldn't mess with the hostname.

(But I could be wrong here).

Best regards,

Valentijn
