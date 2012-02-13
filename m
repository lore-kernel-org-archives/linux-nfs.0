Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:38192 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756422Ab2BMJcS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 04:32:18 -0500
Date: Mon, 13 Feb 2012 10:32:04 +0100
From: <whats_up@gmx.net>
To: Andy Adamson <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120213103204.383f9eef@little-poseidon>
In-Reply-To: <CAHVgHyWYpbuAZ9SFk+oiQmStQC4cnr+yGPvdjag3zT61Cj0KxA@mail.gmail.com>
References: <20120210154526.7b504146@little-poseidon>
 <CAHVgHyUdxUhg3rBHNzf3EX049iqU-Mm2WiCtpAzz3v_yn1J7sQ@mail.gmail.com>
 <20120210172554.5e89e364@little-poseidon>
 <CAHVgHyWYpbuAZ9SFk+oiQmStQC4cnr+yGPvdjag3zT61Cj0KxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> I believe you have not set the Local-Realms, so libnfsidmapd.023 uses
> the default of the upper-case of the local domain-name. Thus the
> nss_gss_print_ids error message:
> 
> > Feb 10 14:45:17 tm rpc.svcgssd[1335]: nss_gss_princ_to_ids:
> > Local-Realm '<MYREALM>': NOT FOUND
> 
> Try setting the Local-Realms =  in /etc/idmapd.conf.

I'm a bit confused because <MYREALM> in the error message is the
correct realm.

I altered the idmapd.conf (server and client). Just be be sure we speak
about the same things:

<MYREALM>:      MYSERVERHOSTNAME.SUB1.DOMAIN.TLD
server:         myserverhostname.sub1.domain.tld
client:    myclienthostname.sub2.sub1.domain.tld

/etc/idmapd.conf  
Domain = myserverhostname.sub1.domain.tld
Local-Realm = MYSERVERHOSTNAME.SUB1.DOMAIN.TLD

> # The following should be set to the local NFSv4 domain name
> # The default is the host's DNS domain name.
> #Domain = local.domain.edu

I wondered if a "local domain name" should include the hostname or not,
thus I tried sub1.domain.tld and also myserverhostname.sub1.domain.tld
The later worked and let the error message disappear from the log. The
rest is the same and mount still hangs.

regards
 knut


server log:

Feb 13 10:23:29 tm rpc.svcgssd[18043]: leaving poll
Feb 13 10:23:29 tm rpc.svcgssd[18043]: handling null request
Feb 13 10:23:29 tm rpc.svcgssd[18043]: sname = root/<client-fqdn>@<MYREALM>
Feb 13 10:23:29 tm rpc.svcgssd[18043]: DEBUG: serialize_krb5_ctx: lucid version!
Feb 13 10:23:29 tm rpc.svcgssd[18043]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Feb 13 10:23:29 tm rpc.svcgssd[18043]: doing downcall
Feb 13 10:23:29 tm rpc.svcgssd[18043]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1329211409 (86400 from now), clnt: root@<client-fqdn>, uid: -1, gid: -1, num aux grps: 0:
Feb 13 10:23:29 tm rpc.svcgssd[18043]: sending null reply
Feb 13 10:23:29 tm rpc.svcgssd[18043]: writing message: \x... 1329125069 0 0 \x02000000 \x...
Feb 13 10:23:29 tm rpc.svcgssd[18043]: finished handling null request
Feb 13 10:23:29 tm rpc.svcgssd[18043]: entering poll

