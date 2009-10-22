From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfsmount.conf: New variables that explicitly set
 default (Release 3)
Date: Thu, 22 Oct 2009 15:48:09 -0400
Message-ID: <4AE0B6F9.4090406@RedHat.com>
References: <4AD9C871.3000400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118AbZJVTsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2009 15:48:22 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9MJmQi1020529
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2009 15:48:26 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-8-21.rdu.redhat.com [10.11.8.21])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9MJmPCP001128
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2009 15:48:26 -0400
In-Reply-To: <4AD9C871.3000400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/17/2009 09:36 AM, Steve Dickson wrote:
> Here is an update to my previous patch that allow the setting
> of both the protocol version and network version from the 
> mount configuration file. Here is the original justification:
> 
>     http://marc.info/?l=linux-nfs&m=125511238831199&w=2
> 
> In this release two global variables are used to keep 
> the default values set in the configuration file. These
> values are then used to initialize the values used in
> the server negotiation. 
> 
> This patch set can be found on the 'mntconf_v3' branch
> on my experimental git tree:
>     git://linux-nfs.org/nfs-utils-exp
> 
> 
Committed..

steved.
