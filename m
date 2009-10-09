From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: protocol version set on command line being
 ignored
Date: Fri, 09 Oct 2009 11:14:47 -0400
Message-ID: <4ACF5367.5030508@RedHat.com>
References: <4ACE01AC.3000806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137AbZJIPPX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 11:15:23 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n99FEwVx018122
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 11:14:58 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-151.rdu.redhat.com [10.11.10.151])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n99FEubX024100
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 11:14:57 -0400
In-Reply-To: <4ACE01AC.3000806-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/08/2009 11:13 AM, Steve Dickson wrote:
> Here is a bug that was found in some recent test cycles...
> 
> 
> Author: Steve Dickson <steved@redhat.com>
> Date:   Thu Oct 8 10:56:57 2009 -0400
> 
>     There are a number of different mount options that can be
>     used to set the protocol version on the command line. The
>     config file code needs to know about each option so the
>     command line value will override the config file value.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
Committed... 

steved
