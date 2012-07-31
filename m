Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754392Ab2GaO4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:56:21 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1343746117.5528.3.camel@lade.trondhjem.org>
References: <1343746117.5528.3.camel@lade.trondhjem.org> <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com, "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NFS: Fix a number of bugs in the idmapper
Date: Tue, 31 Jul 2012 15:56:15 +0100
Message-ID: <6978.1343746575@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> This patch should already be present in nfs-for-next as of yesterday.
> (I've been on a 2 week vacation).

How about the second patch?  I posted an updated version of it just now.

Note that the second patch or something like it is likely to be necessary to
reduce the load on the keyring (you end up having duplicate keys of different
key types that can't be shared).

David
