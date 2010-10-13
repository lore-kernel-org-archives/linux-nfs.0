Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:34773 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab0JMNS7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 09:18:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id D7E55243FF9
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:18:58 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xlV-vxUY62kp for <linux-nfs@vger.kernel.org>;
	Wed, 13 Oct 2010 15:18:56 +0200 (CEST)
Received: from blub.net (095-097-076-243.static.chello.nl [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id E7B55243FF8
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:18:56 +0200 (CEST)
Received: from stout.kantoor.openoffice.nl (stout.kantoor.openoffice.nl [192.168.112.50])
	by blub.net (Postfix) with ESMTP id CBF16300050
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:18:56 +0200 (CEST)
Message-ID: <4CB5B1C0.2010904@blub.net>
Date: Wed, 13 Oct 2010 15:18:56 +0200
From: Valentijn Sessink <valentyn@blub.net>
To: linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
References: <4CB59086.9080108@blub.net> <20101013085628.58f568d7@corrin.poochiereds.net>
In-Reply-To: <20101013085628.58f568d7@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton schreef:
> Valentijn Sessink <valentyn@blub.net> wrote:
>> Is this correct, i.e. svcgssd still needs to be adapted to IPv6? Or
>> should NFS-server/IPv6/Kerberos on Linux just work, i.e. should I
>> re-check my configuration?
> When I last tested it and reviewed it (which was quite some time ago),
> it worked without any issues. rpc.svcgssd doesn't really do much with
> addresses, so it didn't need anything to convert it to IPv6.
> 
> What sort of problems were you having?

>From the user's viewpoint, there was no uid-mapping: everything you
wrote would end up as nobody:nogroup on the server. This happens when
your Kerberos-tickets cannot be validated - hence my pointing at svcgssd
and gssd.

I did test starting rpc.svcgssd and rpc.gssd with -vvvf, and there were
a few suspiciously looking messages. Then I ran out of time :)

Anyway, from your answers I conclude that there is not a reason "per se"
that it cannot work (nor is there a reason it should work ;), so I'll
test again and this time I will gather more extensive logging
information to feed the list with ;)

Best regards,

Valentijn

