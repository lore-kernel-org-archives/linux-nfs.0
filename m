Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50088 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726308AbeIMNrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Sep 2018 09:47:07 -0400
From: =?utf-8?Q?Aur=C3=A9lien?= Aptel <aaptel@suse.com>
To: David Howells <dhowells@redhat.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        sfrench@samba.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: Making the in-kernel DNS resolver handle server lists
In-Reply-To: <17451.1536750676@warthog.procyon.org.uk>
References: <17451.1536750676@warthog.procyon.org.uk>
Date: Thu, 13 Sep 2018 10:38:37 +0200
Message-ID: <87lg854ws2.fsf@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:
> The payload handed to the kernel currently looks like something assembled from
> the data obtained from a bunch of SRV records that have been further looked up
> to A or AAAA.

I was wondering recently if the current kernel API lets you to access
all A/AAAA records in case a same domain uses multiple ones. It seems
not, is this correct?

> In the kernel it might get parsed to something like:
>
> 	struct address {
> 		union {
> 			struct sockaddr_in	sin;
> 			struct sockaddr_in6	sin6;
> 		};
> 	};

You probably want struct sockaddr_storage here.


>
> 	struct server {
> 		unsigned short		port;
> 		unsigned short		pref;		// From SRV
> 		unsigned short		weight;		// From SRV
> 		unsigned char		ipproto;	// IPPROTO_*
> 		unsigned int		nr_addrs;	// May be 0
> 		struct address		*addrs;
> 	};
>
> 	struct server_list {
> 		unsigned int		nr_servers;
> 		struct server		servers[];
> 	};
>
> Is this something that NFS or CIFS (or anything else for that matter) could
> find useful?

That sounds useful indeed. I'm currently thinking about a failover
mechanism for DFS (symbolic links across servers in cifs). The protocol
supports multiple possible targets for the link in case one is down. The
targets are usually using hostnames so with your change we could have a
second layer of failover at the DNS level.

> I also have this loading information from a configuration file as a
> backup/override of the DNS.  Could that also be useful to NFS/CIFS?

Cheers,
-- 
Aurélien Aptel / SUSE Labs Samba Team
GPG: 1839 CB5F 9F5B FB9B AA97  8C99 03C8 A49B 521B D5D3
SUSE Linux GmbH, Maxfeldstraße 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
