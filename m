Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735Ab1FHLiJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2011 07:38:09 -0400
Message-ID: <4DEF5F1F.5090807@RedHat.com>
Date: Wed, 08 Jun 2011 07:38:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ben Greear <greearb@candelatech.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Question on passing extra argument to kernel.
References: <4DEE9324.8030703@candelatech.com>
In-Reply-To: <4DEE9324.8030703@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/07/2011 05:07 PM, Ben Greear wrote:
> On stock Fedora 13, you can add extra options to mount (srcaddr=1.2.3.4)
> and if you patch the kernel to parse it, then all works well
> (mount and/or mount.nfs just passes the options directly to the
> kernel it seems.)
> 
> With the git://git.infradead.org/users/steved/nfs-utils.git tree,
> mount.nfs errors out with 'bad option'.
Try using git://linux-nfs.org/~steved/exports/nfs-utils

> 
> What is the preferred way to go about adding new options?
Post a patch to this list... 

steved.
