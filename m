Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:59625 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760667Ab3DBSjQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:39:16 -0400
Date: Tue, 2 Apr 2013 14:39:07 -0400
From: Jim Rees <rees@umich.edu>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130402183907.GB18900@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364922203.2660.1265.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce wrote:

  No this is not what I am saying.
  The client uses the fully qualified name at the mount command but due to
  the use of a PTR lookup it is fooled into acquiring a ticket for the
  wrong server which will then happily allow you to connect.
  
  Currently:
  The mount command tells the kernel both the server name
  'secure.server.name' and it's IP address 1.2.3.4 however rpc.gssd
  currently completely ignored the server name passed in by the mount
  command (see the 'dummy' variable) and instead uses the ip address to do
  a reverse lookup.
  
  PTR lookup of 1.2.3.4 --- MITM ---> public.server.com
  
  Then it uses the retrieved name (public..) to construct the GSSAPI name
  it wants to connect to, the result is that the name
  nfs@public.server.name is constructed instead of the requested
  nfs@secure.server.com that should be requested.
  
  So the client does ask for the right server but can be easily tricked
  into connecting to another one.
  
  Kerberos itself *is* correctly identifying the server, it's rpc.gssd
  that opened it'sself to being fooled before involving Kerberos.

Ok, I think I understand now. I suggest adding some of that text into the
commit log. And stop using the term "mitm". A mitm attack is used to
convince both ends of a connection that they are talking to each other. DNS
is not a mutually authenticated exchange.

This discussion is making me nervous. It makes me think no one has thought
through the use of kerberos to authenticate nfs connections on linux.
