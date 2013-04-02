Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56741 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601Ab3DBQqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 12:46:38 -0400
Date: Tue, 2 Apr 2013 12:46:31 -0400
From: Jim Rees <rees@umich.edu>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130402164631.GA23840@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364919975.2660.1255.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce wrote:

  It's a MITM setting.
  
  Suppose you have 2 servers:
  
  secure.server.name where you store confidential documents
  public.server.name where everyone have access for reading (and you can
  write)
  
  If you mount -t nfs secure.server.name/export and rely on PTR records
  and an attacker can spoof your PTR request to return public.server.name
  you will end up acquiring a ticket for public.server.name from the KDC.
  Then the attacker will redirect your mount to public.server.name all the
  while you think you have mounted secure.server.name
  
  Now anything you copy there goes to a public server instead of your
  secure server.
  
  Now imagine your secure server is a backup server which gets mounted by
  a cron job every night for backups of sensitive information.

I guess what you're saying is that the client might not know the full name
of the secure server, and could be tricked into thinking it's
public.server.name. That's not what I'd call mitm; kerberos is pretty much
immune to mitm. It's not really a dns mitm either, it's a spoofed reply.

I would be in favor of requiring kerberized nfs clients to know the full
name of the server they're trying to connect to. Kerberized nfs clients
should not be relying on dns for any part of their security. But I guess we
haven't been doing that, and to make that a requirement now would be a
compatibility problem.
