Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:34746 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798Ab0KPTwh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 14:52:37 -0500
Message-ID: <4CE2E0FF.1080201@blub.net>
Date: Tue, 16 Nov 2010 20:52:31 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: no_root_squash (and valid KRB root-ticket)
References: <4CE294DD.6010508@blub.net> <20101116183050.GC3971@fieldses.org>
In-Reply-To: <20101116183050.GC3971@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Op 16-11-10 19:30, J. Bruce Fields schreef:
>> I found that having "no_root_squash" on the server, having a valid
>> Kerberos ticket for root@DOMAIN, does still not give you root rights on
>> a share.
> This is between a linux client and server?

Yes. Not a really recent one though, must be Ubuntu 10.04 server and client.

> Are other kerberos principals mapped as you'd expect?

Yes — it's on our production network, user ID's are mapped without a 
problem. While I'm typing this: I did not check what idmapd says; most 
of the users are in LDAP, while root is just a local user with a 
corresponding local user on the server. Can't think of a reason why this 
should bar root from using the share, but I will check that, tomorrow, 
just to be sure.

V.
