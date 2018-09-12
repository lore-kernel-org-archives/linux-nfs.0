Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:35656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727943AbeILQPW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Sep 2018 12:15:22 -0400
From: David Howells <dhowells@redhat.com>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        sfrench@samba.org
cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-fsdevel@vger.kernel.org
Subject: Making the in-kernel DNS resolver handle server lists
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 12 Sep 2018 12:11:16 +0100
Message-ID: <17451.1536750676@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond, Anna, Steve,

For kAFS, I'm writing something to allow the in-kernel DNS resolver be able to
ask for a server list (eg. the list of VL servers in an AFS cell) and get back
a list of servers and the addresses associated with each server.

This would be requested by passing an "srv=<version>" option in the callout
info.

The payload handed to the kernel currently looks like something assembled from
the data obtained from a bunch of SRV records that have been further looked up
to A or AAAA.

In the kernel it might get parsed to something like:

	struct address {
		union {
			struct sockaddr_in	sin;
			struct sockaddr_in6	sin6;
		};
	};

	struct server {
		unsigned short		port;
		unsigned short		pref;		// From SRV
		unsigned short		weight;		// From SRV
		unsigned char		ipproto;	// IPPROTO_*
		unsigned int		nr_addrs;	// May be 0
		struct address		*addrs;
	};

	struct server_list {
		unsigned int		nr_servers;
		struct server		servers[];
	};

Is this something that NFS or CIFS (or anything else for that matter) could
find useful?

I also have this loading information from a configuration file as a
backup/override of the DNS.  Could that also be useful to NFS/CIFS?

David
