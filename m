From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] how to display fsid on client?
Date: Wed, 13 Jan 2010 15:32:53 -0800
Message-ID: <4B4E5825.1080305@gmail.com>
References: <55270.93264.qm@web37306.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Erik Bryer <erik_bryer@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60627 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655Ab0AMXrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jan 2010 18:47:24 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NVCvq-0006lM-3t
	for linux-nfs@vger.kernel.org; Thu, 14 Jan 2010 10:47:22 +1100
In-Reply-To: <55270.93264.qm-0WRSi9NJipCvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Erik Bryer wrote:
>
> I've tried this many times, read the faq, and so on. Do I misunderstand? Is the st_dev, "ID of device containing file", as read on the client not going to be the same as what is forced by "fsid=n" in the exports file?
>
>   
No, they are *different* IDs. The Linux NFS server's fsid is for export 
purpose (used to construct NFS file handler). It has *nothing* to do 
with "st_dev" obtained from "stat" system call (that is used by Linux 
VFS layer).

To display the linux (nfs) server fsid on client, the easiest way (I 
think) is probably using some network protocol analyzers that know how 
to interpret Linux server's file handler (did you try "ethereal" yet ?). 
If you decode the server's file handler, the fsid you're look for should 
be there.

-- Wendy


------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

