Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blade3.isti.cnr.it ([194.119.192.19]:54085 "EHLO
	BLADE3.ISTI.CNR.IT" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab0K2TC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 14:02:29 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5 #31825) id <01NUU71PU6EOLKQVND@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 18:32:32 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.5 #31825)
 id <01NUU71PAY4WLS5H3C@mx.isti.cnr.it> for linux-nfs@vger.kernel.org; Mon,
 29 Nov 2010 18:32:31 +0100 (MET)
Received: from [192.168.7.52] (firewall.itb.cnr.it [155.253.6.254])
 by mx.isti.cnr.it (PMDF V6.5 #31826)
 with ESMTPSA id <01NUU71OELD6LPP8E4@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 18:32:30 +0100 (MET)
Date: Mon, 29 Nov 2010 18:32:29 +0100
From: Spelic <spelic@shiftmail.org>
Subject: NFSv4 behaviour on unknown users
To: linux-nfs@vger.kernel.org
Message-id: <4CF3E3AD.2040502@shiftmail.org>
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
