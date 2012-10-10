Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.rus.uni-stuttgart.de ([129.69.1.55]:42623 "EHLO
	hydra.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932229Ab2JJPEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Oct 2012 11:04:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by hydra.rus.uni-stuttgart.de (Postfix) with ESMTP id 85A5712B7D8
	for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 17:04:49 +0200 (CEST)
Received: from hydra.rus.uni-stuttgart.de ([127.0.0.1])
	by localhost (hydra.rus.uni-stuttgart.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yYjc-3UldlDx for <linux-nfs@vger.kernel.org>;
	Wed, 10 Oct 2012 17:04:48 +0200 (CEST)
Received: from tindra.iws.uni-stuttgart.de (tindra.iws.uni-stuttgart.de [129.69.98.190])
	by hydra.rus.uni-stuttgart.de (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 17:04:48 +0200 (CEST)
Date: Wed, 10 Oct 2012 17:04:48 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121010150448.GA12518@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 

to provide more details I made tcpdump of the 
"touch .." on two hosts.  The outputfiles for looking in with wireshark
& co are on: 

	http://maultier.iws.uni-stuttgart.de:8080/nfs

But I do not understand much of nfs-protocol. 

Best regards, David
