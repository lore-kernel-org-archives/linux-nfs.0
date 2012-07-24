Return-Path: linux-nfs-owner@vger.kernel.org
Received: from spam.physics.umanitoba.ca ([130.179.72.17]:50844 "EHLO
	hauhet.physics.umanitoba.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755520Ab2GXRD4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 13:03:56 -0400
Received: from [130.179.72.253] (shodan.physics.umanitoba.ca [130.179.72.253])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hauhet.physics.umanitoba.ca (Postfix) with ESMTP id 05FE465946
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 12:03:56 -0500 (CDT)
Message-ID: <500ED5E4.1050902@physics.umanitoba.ca>
Date: Tue, 24 Jul 2012 12:05:40 -0500
From: Maiko Langelaar <maiko@physics.umanitoba.ca>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: 2 NFS server for the same mount point ?
References: <500EBB69.5000205@physics.umanitoba.ca> <20120724155304.GA9721@us.ibm.com>
In-Reply-To: <20120724155304.GA9721@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > Yes, you can.

Just to be on the safe side, I should be a bit more clear on this.

Both of the NFS servers will be running simultaneously, both
exporting the same mount points for the same subnet.

Maiko

