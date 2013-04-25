Return-Path: linux-nfs-owner@vger.kernel.org
Received: from office2.cesnet.cz ([195.113.144.244]:47218 "EHLO
	office2.cesnet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab3DYMuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 08:50:04 -0400
Message-ID: <517923D2.2000002@gmail.com>
Date: Thu, 25 Apr 2013 14:38:42 +0200
From: Jiri Horky <jiri.horky@gmail.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: chuck.lever@oracle.com
Subject: Kerberos security flavors not tried in SETCLIENTID_CONFIRM client
 requests
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

(everything described below is from a client with 3.6.11-gentoo kernel).

When I mount a filesystem that is exported as follows:

/exports 
*(sec=krb5:krb5i:krb5p,rw,fsid=0,sync,no_subtree_check,no_root_squash,insecure,crossmnt)

without specifiying a security flavour on client, the mount will work. 
 From the tcpdump I can tell that the client tries AUTH_UNIX and 
AUTH_NULL flavours before succeeding with RPCSES_GSS. When I do a "ls" 
command in the mounted directory it works fine as well - this time 
clients uses RPCSES_GSS authentication right away.

The problems comes with "cat" command on a file, when the client calls 
SETCLIENID with AUTH_UNIX credentials and AUTH_NULL verifier, which 
successes but then call SETCLIENTID_CONFIRM again with just 
AUTH_UNIX/AUTH_NULL which results in NFS4ERR_WRONGSEC. The client tries 
to all the SETCLIENTID_CONFIRM multiple times, but it does not try 
Kerberos authentication. The WRONGSEC error is then propagated as EIO to 
the application.

I noticed patches from Chuck Level on 03/16/2013 which fix problems with 
security flavours handling but I am not sure whether they are supposed 
to fix thix particular problem as well. It would take me considerable 
amount of time to test it so I would appreciate if you could comment on 
that.

Regards
Jiri Horky


