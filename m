From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: multithreaded mountd fixes
Date: Fri, 12 Feb 2010 14:03:46 -0500
Message-ID: <4B75A612.4070501@RedHat.com>
References: <20100128211454.29681.24752.stgit@case.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756926Ab0BLTDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 14:03:49 -0500
In-Reply-To: <20100128211454.29681.24752.stgit-PhfrMOq4MEUPybYDWDrblq0bRtRcJeJQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/28/2010 04:26 PM, Ben Myers wrote:
> Hey Steve,
> 
> The following fixes a problem with mountd where you get backed up behind the
> rmtab lock.  It may have happened that an xflock timed out and stat failed so
> the filedescriptor was leaked in mountlist_list and the lock never released.
> Skipping the fdatasync has also helped performance-wise.
> 
> Tested very lightly on TOT and more heavily on 1.0.7 where this bug was
> discovered.
Committed... 

steved.
