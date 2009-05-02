From: =?ISO-8859-15?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] NFS: Do not display the setting of the "intr" mount
 option
Date: Sat, 2 May 2009 10:12:31 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0905021010320.19638@maggie.lkpg.cendio.se>
References: <20090501163402.25637.67939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1085729976-1241251837=:19638"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:61714 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbZEBIMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 May 2009 04:12:32 -0400
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 91C175F00FC
	for <linux-nfs@vger.kernel.org>; Sat,  2 May 2009 10:12:31 +0200 (CEST)
In-Reply-To: <20090501163402.25637.67939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1085729976-1241251837=:19638
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15; FORMAT=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LFD.2.00.0905021010381.19638-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>

On Fri, 1 May 2009, Chuck Lever wrote:

> The "intr" mount option has been deprecated for a while, but
> /proc/mounts continues to display "nointr" whether "intr" or "nointr"
> has been specified for a mount point.
>
> Since these options do not have any effect, simply do not display
> them.

Does this mean that "intr" is default now? Will the "intr" mount option 
still be accepted/ignored in the future?


Best regards, 
---
Peter Åstrand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.com
Wallenbergs gata 4
583 30 Linköping	Phone: +46-13-21 46 00
--789237761-1085729976-1241251837=:19638--
