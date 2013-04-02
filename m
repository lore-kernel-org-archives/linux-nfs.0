Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932977Ab3DBSso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:48:44 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <20130402183907.GB18900@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <20130402150049.GA526@umich.edu>
	 <1364919975.2660.1255.camel@willson.li.ssimo.org>
	 <20130402164631.GA23840@umich.edu>
	 <1364922203.2660.1265.camel@willson.li.ssimo.org>
	 <20130402183907.GB18900@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 14:48:39 -0400
Message-ID: <1364928519.2660.1279.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 14:39 -0400, Jim Rees wrote:
> Simo Sorce wrote:
> 
>   No this is not what I am saying.
>   The client uses the fully qualified name at the mount command but due to
>   the use of a PTR lookup it is fooled into acquiring a ticket for the
>   wrong server which will then happily allow you to connect.
>   
>   Currently:
>   The mount command tells the kernel both the server name
>   'secure.server.name' and it's IP address 1.2.3.4 however rpc.gssd
>   currently completely ignored the server name passed in by the mount
>   command (see the 'dummy' variable) and instead uses the ip address to do
>   a reverse lookup.
>   
>   PTR lookup of 1.2.3.4 --- MITM ---> public.server.com
>   
>   Then it uses the retrieved name (public..) to construct the GSSAPI name
>   it wants to connect to, the result is that the name
>   nfs@public.server.name is constructed instead of the requested
>   nfs@secure.server.com that should be requested.
>   
>   So the client does ask for the right server but can be easily tricked
>   into connecting to another one.
>   
>   Kerberos itself *is* correctly identifying the server, it's rpc.gssd
>   that opened it'sself to being fooled before involving Kerberos.
> 
> Ok, I think I understand now. I suggest adding some of that text into the
> commit log.

To be honest this is a well known problem in the kerberos community, I
will see if I can find a public text that references this problem and
add a link to it in the commit log ?

It's a bit of a long explanation otherwise ... maybe I can point at this
thread in the archives ?

>  And stop using the term "mitm". A mitm attack is used to
> convince both ends of a connection that they are talking to each other. DNS
> is not a mutually authenticated exchange.

Well it is still a sort of Man in the Middle, as you also have to
redirect communications (nfsv4 uses TCP) for it to be effective, it is
just not exploiting a crypto issue.

> This discussion is making me nervous. It makes me think no one has thought
> through the use of kerberos to authenticate nfs connections on linux.

I think this is just an oversight, this 'bug' has been present since the
original patches have been merged in.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

