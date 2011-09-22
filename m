Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20864 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab1IVTXI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 15:23:08 -0400
Subject: Re: Read Only Issue from RHEL 6
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Leo Chan <admin@kzeouki.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 22 Sep 2011 15:23:09 -0400
In-Reply-To: <20110922175117.GD32034@qccos6.kze.local>
References: <20110922175117.GD32034@qccos6.kze.local>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316719389.3968.16.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-22 at 13:51 -0400, Leo Chan wrote: 
> I want to submit a possible bug report that not able to get mount RW from RHEL 6.0. (RO only) We are able to mount RW  from a folder with symbolic link pointing to the mount point. But not mounting directly at the folder. Please let me know if you need further information.

This is the wrong forum for discussing Red Hat kernel bugs unless you
can show that they also apply to the upstream kernels.

Have you tried filing a bug report with bugzilla.redhat.com?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

