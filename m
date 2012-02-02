Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:38274 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab2BBGjq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 01:39:46 -0500
Received: from [192.168.1.13] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q126eYf3009193
	for <linux-nfs@vger.kernel.org>; Thu, 2 Feb 2012 07:40:40 +0100
Message-ID: <4F2A2F9E.6030908@steve-ss.com>
Date: Thu, 02 Feb 2012 07:39:26 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: where can I ask user qns about nfs4?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I want to ask a question about nfs4 keytabs and Samba 4. I've tried 
asking here, on the Samba 4 list and on the openSUSE list (which is my 
Linux distribution) but they refer me to an nfs list. I see that this 
list is only for nfs devs.

I don't want to waste your time here but my question is just this:

My nfs4 server has a service principal nfs/server.domain.name

I already use nfs4 to serve my Linux clients. I'm going to kerberize it. 
My clients already have machine and host principals. What else do they need?

1. nfs/client.domain.name
2. nfs/server.domain/name
3. neither
4. both

The Google doco is contradictory and confusing to say the least. If you 
can't help, could you point me in the right direction?

Thanks so much fr your time,
Steve

