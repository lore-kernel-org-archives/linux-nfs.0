From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Move common code into support
Date: Wed, 13 Oct 2010 10:21:51 -0400
Message-ID: <4CB5C07F.2080902@RedHat.com>
References: <20101005202438.GA15113@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab0JMOV4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 10:21:56 -0400
In-Reply-To: <20101005202438.GA15113-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/05/2010 04:24 PM, Jim Rees wrote:
> This is a re-worked version of David P. Quigley's patch sent to the list on
> 22 Jun 2010.  I just made it apply against current source.
> 
> There are several source files and headers present in the ./utils/idmapd
> directory which are also usable in a doimapd daemon. Because of this we move
> that support into the support directory such that it can be shared by both
> daemons.
Committed...

steved.
