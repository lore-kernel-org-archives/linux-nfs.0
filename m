Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:56260 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761420Ab2FGTdm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 15:33:42 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 0242912AFE9
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jun 2012 21:33:40 +0200 (CEST)
Date: Thu, 7 Jun 2012 21:33:40 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect
 mount option
Message-ID: <20120607193339.GT12795@8bytes.org>
References: <20120607150456.GO12795@8bytes.org>
 <4FD0C4C2.8020605@netapp.com>
 <20120607155006.GR12795@8bytes.org>
 <4FD0CEB0.9040804@netapp.com>
 <20120607160109.GS12795@8bytes.org>
 <4FD0E382.8050800@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD0E382.8050800@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 07, 2012 at 01:23:14PM -0400, Bryan Schumaker wrote:
> On 06/07/2012 12:01 PM, Joerg Roedel wrote:

> What does /etc/exports look like on the server?  You may have to mount
> it as "lemmy:/" when using NFS v4.

It does not use NFSv4. The exact same command line works fine on v3.4 :)
The /etc/exports line is:

/data/repos	*(ro,no_subtree_check)

> 
> What distro are you using?  I haven't been able to get the incorrect mount option error you're seeing.

The client is running Ubuntu 10.04 amd64 desktop with development kernel
and the "server" is my workstation, running Ubuntu 12.04 amd64 desktop
with distro kernel (3.2 based).

Regards,

	Joerg

