From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: 2.6.38.6 - state manager constantly respawns
Date: Mon, 16 May 2011 14:45:45 -0400
Message-ID: <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com>
References: <4DD16FA8.4030602@uw.edu>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Harry Edmon <harry@uw.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63331 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1EPSp5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 14:45:57 -0400
In-Reply-To: <4DD16FA8.4030602@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 16, 2011, at 2:40 PM, Harry Edmon wrote:

> I have a NFSv4 server and client running 2.6.38.6 with Debian squeeze.  On my client kthreadd is running constantly, and my processes accounting file is full of entries with the PPID of kthreadd and the command being the IP number of the server with "-ma" appended, e.g.
> 
> 192.168.1.12-ma
> 
> I believe this is the nfsv4 state manager being constantly being respawned by kthreadd and quickly exiting.   There are no log entries from the state manager (or anything else from NFS).  When I reboot the system with the Debian provided 2.6.32 kernel the problem goes away.  Does anyone have an idea why this would be occurring?   I have included the kernel config file from the client.

One thing you could do to capture more information about the problem is to run a network trace on a client that is in this state.  The procedures and error codes on the wire might be illuminating.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




