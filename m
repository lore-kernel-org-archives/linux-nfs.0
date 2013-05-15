Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:38864 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932638Ab3EOOrG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 10:47:06 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r4FEl4hn026281
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 14:47:05 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4FEl5RP017777
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 14:47:05 GMT
Received: from abhmt107.oracle.com (abhmt107.oracle.com [141.146.116.59])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4FEl4Pa017765
	for <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 14:47:04 GMT
From: Nick Alcock <nick.alcock@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: Some per-machine NFS export options are broken by 11ba3b1e01b67b7d19f26fba94fabdb60878e809
Date: Wed, 15 May 2013 15:47:00 +0100
Message-ID: <87vc6kxpuj.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs-utils commit 11ba3b1e01b67b7d19f26fba94fabdb60878e809 has
exacerbated the effects of a bug around sec= option specification, or
possibly around default option ordering (depending on how you look at
it).

Default options in /etc/exportfs, e.g. "-foo,bar" are, as I understand
it, supposed to be overrideable by per-machine options, e.g., this
works:

/foo -ro one.machine two.machine(rw) three.machine

This should be equivalent to

/foo one.machine(ro) two.machine(rw) three.machine(ro)

(or, at least, there is no other way of doing this that I can see,
without massively repeating mount options, which is the old plague which
default options are supposed to fix).

Unfortunately, this is not true for the sec= option, because specifying
sec= forces the implicit addition of a bunch of other options courtesy
of secinfo_show(), which is used when populating /var/lib/nfs/etab.

Unfortunately, Chuck's commit, by implicitly specifying sec= if not
already present, turned this from a nearly-invisible bug that only
affected people who used sec= in the default option string to a bug that
affects everyone who uses default options to specify read-writeness for
some mounts rather than others, and quite possibly breaks read-write
mounts and other things for everyone who uses per-machine mount options
at all. e.g., for me, this line in /etc/exportfs:

/usr/src -fsid=16,no_root_squash,no_subtree_check,async mutilate(rw)

produced this line in etab

/usr/src        mutilate.wkstn.nix(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=16,anonuid=65534,anongid=65534)

before that patch, and 

/usr/src        mutilate.wkstn.nix(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=16,anonuid=65534,anongid=65534,sec=sys,ro,no_root_squash,no_all_squash)

afterwards. Reverting 11ba3b1e fixes it, but clearly it is not the
culprit itself, because you can reproduce it in an nfs-utils with this
patch reverted by just adding 'sec=sys' after 'async' in the exportfs
line above: the bug is deeper.

I *think* -- but am not confident enough to try to fix it -- that the
actual bug is that the options are being emitted in the wrong order:
since later options supercede earlier ones, the per-machine options
should be emitted last, rather than first, as at present.

I think. Probably. Maybe. I could be wrong, but this is clearly a
behaviour change and it breaks my setup :)
