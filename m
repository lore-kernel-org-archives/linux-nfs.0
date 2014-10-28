Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-3.ukservers.net ([217.10.138.152]:41261 "EHLO
	auth-3.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbaJ1KMm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 06:12:42 -0400
Date: Tue, 28 Oct 2014 10:12:32 +0000 (GMT)
From: Carl Hetherington <cth@carlh.net>
To: Chuck Lever <chuck.lever@oracle.com>
cc: David Howells <dhowells@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com>
Message-ID: <alpine.DEB.2.02.1410281006010.27485@main.carlh.net>
References: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Subject: Re: NFSv4 idmap misbehavior
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Chuck,

[snip]

> After the test has been running for ten minutes, the id_resolv
> keys expire, and id_legacy keys appear. Before the above commit,
> the id_resolv keys would simply be refreshed and operation
> would continue normally.

This sounds a lot like a bug I have seen, our investigations into which
are summarised here:

https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1124250

There's an inexpertly written (by me) patch in that bug report (which I
posted to this list recently, too) which (in a nutshell) makes the
idmapper code call up to userspace to get a new key when the current ones
have expired.

I don't know whether that's the right approach, but I'm sure someone here
more qualified can comment.

Best regards,
Carl
