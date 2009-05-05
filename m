From: =?ISO-8859-15?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] NFS: Do not display the setting of the "intr" mount
 option
Date: Tue, 5 May 2009 08:36:22 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0905050832340.6736@maggie.lkpg.cendio.se>
References: <20090501163402.25637.67939.stgit@ingres.1015granger.net>  <alpine.LFD.2.00.0905021010320.19638@maggie.lkpg.cendio.se>  <382F5CF6-4D1A-4B1E-8E17-B6426CFC3A03@oracle.com> <1241455743.5754.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-57686459-1241505382=:6736"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:61012 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714AbZEEGgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2009 02:36:23 -0400
In-Reply-To: <1241455743.5754.10.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-57686459-1241505382=:6736
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT

On Mon, 4 May 2009, Trond Myklebust wrote:

>> Since 2.6.25, the behavior of the NFS client has been a mix of the
>> two.  I believe the current behavior is that SIGKILL can terminate an
>> NFS operation, but all other signals are deferred until pending NFS
>> operations complete.

I guess this means that commands cannot be terminated using Ctrl-C, since 
that generates a SIGINT? If so, this is a change for the worse.


>> The mount command continues to accept both options, but neither have
>> any effect on the client's behavior (both options are no-ops).
>
> Note that this behaviour is true of local filesystems too, since
> generic_file_read() has been changed to call lock_page_killable()
> instead of the uninterruptible lock_page().

I see. However, it's much more common with unreachable network servers 
than unreachable local block devices.


Best regards, 
---
Peter Åstrand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.com
Wallenbergs gata 4
583 30 Linköping	Phone: +46-13-21 46 00
--789237761-57686459-1241505382=:6736--
