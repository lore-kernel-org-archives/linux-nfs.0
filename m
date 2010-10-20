Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:42086 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab0JTLBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 07:01:22 -0400
Message-ID: <4CBECBFF.2050802@blub.net>
Date: Wed, 20 Oct 2010 13:01:19 +0200
From: Valentijn Sessink <valentyn@blub.net>
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
References: <4CB59086.9080108@blub.net>	<20101013125656.GA5197@merit.edu>	<20101013095216.5b9b31a7@corrin.poochiereds.net>	<4CB5BA8F.2090608@blub.net> <20101013104937.358fe122@corrin.poochiereds.net>
In-Reply-To: <20101013104937.358fe122@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff, list,

Jeff Layton schreef:
> It sounds more like you have a problem with idmapping rather than
> anything krb5 specific, but I'm not sure why that would be the case
> with sec=krb5 and not with sec=sys.

Well, I did, in fact. At least, that is what I'm currently seeing with
another system, where "networkmanager" messes with the hosts-file, and
as a result, effectively wipes out the FQDN. Thus, idmapd thinks that
"localdomain" (added by networkmanager - why?? - no that's not a
question, just venting my frustration ;) was a good guess to test the
logged in user against:

rpc.idmapd: nss_getpwnam: name 'valentyn@kantoor.openoffice.nl' domain
'localdomain': resulting localname '(null)'

(We run idmapd relying on DNS instead of a "Domain = " clause, because
we thought that made us flexible - I'll rethink that decision.)

V.
