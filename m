Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:52500 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535Ab0JTMFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 08:05:22 -0400
Date: Wed, 20 Oct 2010 08:05:19 -0400
From: Jim Rees <rees@umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
Message-ID: <20101020120519.GA3848@merit.edu>
References: <4CB59086.9080108@blub.net>
 <20101013125656.GA5197@merit.edu>
 <20101013095216.5b9b31a7@corrin.poochiereds.net>
 <4CB5BA8F.2090608@blub.net>
 <20101013104937.358fe122@corrin.poochiereds.net>
 <4CBECBFF.2050802@blub.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CBECBFF.2050802@blub.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Valentijn Sessink wrote:

  Well, I did, in fact. At least, that is what I'm currently seeing with
  another system, where "networkmanager" messes with the hosts-file, and
  as a result, effectively wipes out the FQDN.

You mean resolv.conf?  This is one of my gripes with network manager.  I
usually un-install it, or "chattr +i resolv.conf".

The usual fix for idmapd is to set the domain in /etc/idmapd.conf.
