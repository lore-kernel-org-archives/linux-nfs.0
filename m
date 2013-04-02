Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:51554 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932339Ab3DBPA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 11:00:59 -0400
Date: Tue, 2 Apr 2013 11:00:49 -0400
From: Jim Rees <rees@umich.edu>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130402150049.GA526@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364910351.2660.1243.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce wrote:

  The attached patch adds a new command line switch to rpc.gssd to avoid
  PTR resolution when possible.
  
  The current code *depends* on PTR resolution for GSSAPI authentication
  and this is *bad*.
  It imposes an annoying, and unnecessary, constraint on the correctness
  of DNS resolution, which prevents mounts from working in networks where
  the PTR record cannot be easily controlled (for example networks where
  the forward name is reasonable while the PTR is set to some artificial
  name based on the IP address or so that is not the canonical name or
  where no PTR exist at all).
  
  Depending on PTR resolution for GSSAPI is also very bad practice because
  it opens up DNS spoofing attacks where an attacker can try to redirect a
  user to the wrong server fooling mutual authentication, and induce a
  user to trust improper data or disclose (by copying on the impostor
  server) data that should be confidential.

What happens if it's a partially qualified domain name?

Wouldn't it be better to use something like inet_pton?

I agree that insisting on correct PTR records is a bad idea, but I don't
understand your threat model. It shouldn't be possible for an attacker to do
anything bad by redirecting the client to a spoof server. If it is possible,
we've got bigger problems. How do you think that would work exactly?
