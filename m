Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:53621 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab1DFOat (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 10:30:49 -0400
Received: from [96.31.168.206] (helo=mail.parallels.com)
	by mx2.parallels.com with esmtps (TLSv1:AES128-SHA:128)
	(Exim 4.74)
	(envelope-from <rlandley@parallels.com>)
	id 1Q7Tkv-00049S-EN
	for linux-nfs@vger.kernel.org; Wed, 06 Apr 2011 10:30:49 -0400
Message-ID: <4D9C7916.5030907@parallels.com>
Date: Wed, 6 Apr 2011 09:30:46 -0500
From: Rob Landley <rlandley@parallels.com>
To: <linux-nfs@vger.kernel.org>
Subject: What's nlmsvc_proc_share() for?
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm reading through the fs/lockd code, and I read grace.c and svcshare.c
and code such as nlmsvc_share_file() only seems to get called from
nlmsvc_proc_share() (and its cut-and-paste twin nlm4svc_proc_share())...

And as far as I can grep, those last two functions are never called from
anywhere in the kernel source.

The comments say this is for "DOS shares", which presumably doesn't mean
what I think it means because DOS used netbios, not NFS...

What's this code for, and where does it get used?  Is it something out
of tree, or some header #define that's glued##together that I'm not
picking up via grep...?

Rob
