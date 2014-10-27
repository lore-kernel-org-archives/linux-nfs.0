Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:21025 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbaJ0OoN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2014 10:44:13 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFSv4 idmap misbehavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <17204.1414405979@warthog.procyon.org.uk>
Date: Mon, 27 Oct 2014 10:44:07 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <89017554-D9A0-4778-9AF3-1738E68230D9@oracle.com>
References: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com> <17204.1414405979@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David-

On Oct 27, 2014, at 6:32 AM, David Howells <dhowells@redhat.com> wrote:

> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> After the test has been running for ten minutes, the id_resolv
>> keys expire, and id_legacy keys appear. Before the above commit,
>> the id_resolv keys would simply be refreshed and operation
>> would continue normally.
>> 
>> # grep id_ /proc/keys
>> 00f0a664 I--Q-N-     1  42s 3b010000     0     0 id_legacy uid:cel@oracle.com
> 
> The 'N' flag indicates that the key is negatively instantiated - ie. the
> upcall to instantiate them failed in some way.  Keys so marked will cause key
> lookups to return ENOKEY (or maybe some other error if keyctl_reject() was
> used).
> 
> Failure can be due to the key being properly negatively instantiated
> (keyctl_negate() or keyctl_reject()) or the userspace side of instantiation
> exiting or otherwise dying before it managed to instantiate the key.
> 
> Is there anything to actually process the id_legacy upcall?  It appears
> they're all negatively instantiated.

rpc.idmapd isn’t running on this system, so no. Legacy idmapping is
normally disabled on EL6 update 4 AFAICT.

There is an /etc/request-key.d/id_resolver.conf file, and
/usr/sbin/nfsidmap is there. On another system I previously tried
using only rpc.idmapd, and it didn’t resolve the sudden ownership
change issue.

There should be no reason to switch to using the legacy ID mapper
upcall if the key resolution infrastructure is working. Before the
“KEYS: Expand the capacity . . . ” commit, id_legacy keys do not
appear in /proc/keys.

That leads me to believe something that commit did is preventing
expired id_resolv keys from getting renewed.

> Can you stick "#define __KDEBUG" at the top of security/keys/request_key.c,
> rebuild and look in dmesg?

Thanks, I’ll give that a try and report back.

> Also, /sbin/request-key logs to syslog if it can't find a match in its config
> file.

I didn’t see any relevant messages in /var/log/messages, but I may
have overlooked something.

More recent kernels change the key resolver interface to require
key_revoke instead of key_invalidate. I’ve seen /var/log/messages
complaints about that on other EL6 systems running kernels newer
than 3.16.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



