Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:42373 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894Ab0JTMuL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 08:50:11 -0400
Date: Wed, 20 Oct 2010 08:50:07 -0400
From: Jim Rees <rees@umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
Message-ID: <20101020125007.GA4159@merit.edu>
References: <4CB59086.9080108@blub.net>
 <20101013125656.GA5197@merit.edu>
 <20101013095216.5b9b31a7@corrin.poochiereds.net>
 <4CB5BA8F.2090608@blub.net>
 <20101013104937.358fe122@corrin.poochiereds.net>
 <4CBECBFF.2050802@blub.net>
 <20101020120519.GA3848@merit.edu>
 <4CBEDC75.6020503@blub.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CBEDC75.6020503@blub.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Valentijn Sessink wrote:

  Jim Rees schreef:
  >   another system, where "networkmanager" messes with the hosts-file, and
  > You mean resolv.conf?
  
  No, /etc/hosts

That's evil.  The 127 net addresses have always been listed in /etc/hosts as
just "localhost" with no fqdn, and everything worked fine.  I will add this
to my already long list of reasons to hate network manager.

  But I guess I'm being corrected by reality.

Ha!
