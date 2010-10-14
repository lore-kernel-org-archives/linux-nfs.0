Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.166.172.106]:53554 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266Ab0JNLsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 07:48:31 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o9EBmTot026433
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 13:48:29 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o9EBmT5I032527
	for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 13:48:29 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o9EBmTAO023368
	for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 13:48:29 +0200
Message-ID: <4CB6EE0D.5060303@cea.fr>
Date: Thu, 14 Oct 2010 13:48:29 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: Effect of NFS4ERR_DELAY on the client
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have a question about NFS4ERR_DELAY. What is the behavior of the 
client when such an error is returned. Does it retry ? If yes, how many 
times and with what kind of interval between each retry ?
Is the behavior similar to what the NFSv3 client when receiving 
NFS3ERR_JUKEBOX ?
My purpose is to run NFSv4.x on top of a namespace whose entries can be 
migrated : opening a file may require staging it (in this case 
NFS4ERR_DELAY and NFS3ERR_JUKEBOX will be returned)

     Philippe
