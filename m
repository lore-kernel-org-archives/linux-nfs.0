Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.isti.cnr.it ([194.119.192.4]:2164 "EHLO mx2.isti.cnr.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab0K2SNa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 13:13:30 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5 #31825) id <01NUU8G4R3U8LKRFF4@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 19:12:24 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.5 #31825)
 id <01NUU8G3MMIOLS5EFX@mx.isti.cnr.it> for linux-nfs@vger.kernel.org; Mon,
 29 Nov 2010 19:12:22 +0100 (MET)
Received: from [192.168.7.52] (firewall.itb.cnr.it [155.253.6.254])
 by mx.isti.cnr.it (PMDF V6.5 #31826)
 with ESMTPSA id <01NUU8G3GSWOLPP5YT@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 19:12:22 +0100 (MET)
Date: Mon, 29 Nov 2010 19:12:21 +0100
From: Spelic <spelic@shiftmail.org>
Subject: NFSv4 behaviour on unknown users
To: linux-nfs@vger.kernel.org
Message-id: <4CF3ED05.3070401@shiftmail.org>
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello all
we recently moved to nfsv4 from v3.

I'm currently using idmapd and not kerberos.

I noticed that now, with idmapd (and with idmapd is the only way I know 
for configuring nfsv4 for now), users that are not known at server side 
are squashed to nobody / nogroup  (65534 / 65534).
And a chown by root from the client fails if the user is not known at 
server side.

That's a problem... now we need ldap everywhere...

We were often using NFS for exporting some diskspace to machines on an 
as-needed basis,
so this new behaviour complicates the things greatly for us :-/
It's almost easier to setup iSCSI targets now :-((

Is there a way to have nfsv4 with the behaviour of users of nfsv3, that 
is, using numeric IDs instead of the names, like: "nfsserver, don't care 
if you don't know the user, just give me the numeric ID for the file..."

Thank you
