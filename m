Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:54449 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935096Ab0KQSwn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:52:43 -0500
Message-ID: <4CE42474.7020604@blub.net>
Date: Wed, 17 Nov 2010 19:52:36 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Kevin Coffman <kwc@citi.umich.edu>, Steve Dickson <SteveD@redhat.com>,
        Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com> <4CE2AA3B.6070302@openoffice.nl> <4CE2DF2D.9070603@blub.net> <20101116201753.GB4482@merit.edu> <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com> <20101116205436.GA4595@merit.edu> <44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com> <4CE3F249.8050301@RedHat.com> <C2312B32-B190-41C4-A4C8-C29231DBA305@oracle.com> <AANLkTinJyFHom5JQg5s+yX+6NRBw01S6a9gbwtk5WaLB@mail.gmail.com> <013E9F9C-F4F8-47E6-939D-1B0D893B6988@oracle.com> <AANLkTi=CgbEAewXEtErN5KxmNyWCL8-Jqc69v67cgZ2J@mail.gmail.com> <6980C086-795B-49EF-8F93-8C49A51E35CF@oracle.com>
In-Reply-To: <6980C086-795B-49EF-8F93-8C49A51E35CF@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Op 17-11-10 18:51, Chuck Lever schreef:
> The hostname is added to localhost entries in /etc/hosts because some
> applications require at least one entry with the local host's
> hostname in /etc/hosts.  When a system comes up with all of its
> network interfaces offline and without any IP addresses assigned,
> what else can be done?

Read /etc/hostname?

Adding "localhost" entries to /etc/hosts does nothing for applications 
that require an entry with the hostname in /etc/hosts, *unless* the 
hostname is "localhost". Now as Networkmanager (apparently) sets the 
hostname to "localhost", I can see why Networkmanager wants to add 
"localhost" to /etc/hosts afterwards. But hey, we might as well set the 
hostname to everyone.loves.networkmanager, then add *that* to /etc/hosts 
and run into problems.

Please note, that /etc/hosts has nothing to do with the hostname, it's 
only a way to statically (and locally) add things to the resolver.
[...]
> for the host is added to /etc/hosts, and then added back to the
> localhost entries when all network interfaces are disabled.

I don't think adding or not adding them to /etc/hosts makes any 
difference. I'd guess that calling sethostname() causes problems.

V.
