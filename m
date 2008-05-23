From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Fri, 23 May 2008 15:08:59 -0400
Message-ID: <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
 <20080519144806.GB7622@fieldses.org>
 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com> <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com
 >
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6707 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262AbYEWTJO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2008 15:09:14 -0400
In-Reply-To: <9e8c52a20805230744m2f7488e5q2867674f2987444-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
 >
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <20080519144806.GB7622@fieldses.org>
 <9e8c52a20805230744m2f7488e5q2867674f2987444-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:44 AM 5/23/2008, Alexander Borghgraef wrote:
> Is ext3 known for time resolution issues? Switching to a different fs
>could prove problematic, but I could always ask the sysadmin to move
>my home dir to my client machine, there should be enough space so that
>would rule out any synchronization problems.

Yes, ext3's timestamps resolve to (only) one second. Use the stat(1)
command to see them. They cause problems for NFS, which depends
on them for its consistency checks. Other filesystems and servers do
not have this issue.

> The main thing here is that I'd like to understand why this is
>happening? What does it mean when ls returns something like:
>
>d????????? ? ?        ?          ?                ? cur

This is something very different. (I'm assuming this "ls" was done on the
NFS mount and not the server itself.) Usually, this happens because there
are no attributes available locally - ls seems to know only the filetype
(directory) and filename (cur). What client kernel version are you running?

Tom.

