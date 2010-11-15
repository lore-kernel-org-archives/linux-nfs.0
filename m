Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17288 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933112Ab0KORkk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 12:40:40 -0500
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id oAFHecBX024517
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 17:40:40 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id oAFBOCv0023136
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 17:40:37 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Strange rpc.svcgssd behavior
Date: Mon, 15 Nov 2010 12:39:49 -0500
Message-Id: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've just set up a Linux KDC with a Linux NFS server (Fedora 13 with the latest updates).

rpc.svcgssd fails to start on the NFS server.

 ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS failure.  Minor code may provide more information - Key table entry not found
 unable to obtain root (machine) credentials
 do you have a keytab entry for nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab?

I do have an entry for nfs/<your.host>@<YOUR.REALM> in /etc/krb5.keytab.  The problem is that /etc/hosts looks like this:

 192.168.1.58	your.host	your	# Added by NetworkManager
 127.0.0.1	localhost.localdomain	localhost
 ::1		your.host your	localhost6.localdomain6 localhost6

Removing "your.host	your" from the "::1" entry makes this problem go away -- rpc.svcgssd starts up as expected.

Now I reboot, and NetworkManager happily adds "your.host	your" back to the "::1" entry, and rpc.svcgssd fails again.  I haven't tried this, but I suspect if the ::1 entry weren't there, NM would add "your.host.net	your" to the IPv4 loopback entry, and we'd have the same problem.

At a glance, it looks like the local hostname is determined in a library, and not in rpc.svcgssd.  This really needs to be more robust.

I see the "-p principal" option in the latest nfs-utils, but it doesn't seem to be supported in Fedora 13's rpc.svcgssd.  Is this the workaround?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




