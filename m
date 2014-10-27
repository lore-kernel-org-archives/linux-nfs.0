Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbaJ0KdH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2014 06:33:07 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com>
References: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dhowells@redhat.com, Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 idmap misbehavior
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 27 Oct 2014 10:32:59 +0000
Message-ID: <17204.1414405979@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> wrote:

> After the test has been running for ten minutes, the id_resolv
> keys expire, and id_legacy keys appear. Before the above commit,
> the id_resolv keys would simply be refreshed and operation
> would continue normally.
> 
> # grep id_ /proc/keys
> 00f0a664 I--Q-N-     1  42s 3b010000     0     0 id_legacy uid:cel@oracle.com

The 'N' flag indicates that the key is negatively instantiated - ie. the
upcall to instantiate them failed in some way.  Keys so marked will cause key
lookups to return ENOKEY (or maybe some other error if keyctl_reject() was
used).

Failure can be due to the key being properly negatively instantiated
(keyctl_negate() or keyctl_reject()) or the userspace side of instantiation
exiting or otherwise dying before it managed to instantiate the key.

Is there anything to actually process the id_legacy upcall?  It appears
they're all negatively instantiated.

Can you stick "#define __KDEBUG" at the top of security/keys/request_key.c,
rebuild and look in dmesg?

Also, /sbin/request-key logs to syslog if it can't find a match in its config
file.

David
