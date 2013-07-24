Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:43849 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab3GXNLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 09:11:03 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.6/8.14.6) with ESMTP id r6OD3Ubd000578
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jul 2013 15:03:30 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id r6OD3Rsi032382
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jul 2013 15:03:27 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <20130724091856.GA30866@pfmaster>
From: spam@altium.nl (Dick Streefland)
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not available?
Content-Type: text/plain; charset=us-ascii
Message-ID: <6f01.51efd09f.c2ac3@altium.nl>
Date: Wed, 24 Jul 2013 13:03:27 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Funk <pf@artcom-gmbh.de> wrote:
| We've researched this question for quite a while now and nobody here
| found a solution to the following problem:
| 
|  1: A Linux computer is NFS client of some other Linux NFS server
|     and has some active mounts and some processes working with files 
|     on that NFS server.  
| 
|  2: Now the NFS server becomes unavailable and a system administrator 
|     wants to clean up the situation on the NFS client computer without 
|     having to reboot this client computer.
| 
| Is this possible?  And if how exactly?

What you could try is temporarily add the IP number of the dead NFS
server to another NFS server. The other NFS server should reject any
request for the dead mount, and the client can continue with an error.

-- 
Dick

