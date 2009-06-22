From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Set all verbose types in gssd daemons.
Date: Mon, 22 Jun 2009 09:15:33 -0400
Message-ID: <4A3F83F5.7070704@RedHat.com>
References: <4A2938FE.2070903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38269 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506AbZFVNSh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2009 09:18:37 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n5MDIeiS018491
	for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2009 09:18:40 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n5MDIdax029402
	for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2009 09:18:39 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-40.bos.redhat.com [10.16.10.40])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n5MDIcBx031649
	for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2009 09:18:39 -0400
In-Reply-To: <4A2938FE.2070903-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steve Dickson wrote:
> I founded it very handy to have library verbosity enabled
> when verbosity is enabled on either the gssd or 
> svcgssd daemons. 
> 
> So this patch will set the verbosity level in the 
> librpcsecgss library and in the libnfsidmapd (for svcgssd) 
> when verbosity level is set by the '-v' flag it on
> either daemon.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ----------------------------------------------
> 
Committed...

steved.
