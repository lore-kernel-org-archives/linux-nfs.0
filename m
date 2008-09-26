From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 07:50:27 -0400
Message-ID: <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com> <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "howard chen" <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbYIZLwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 07:52:23 -0400
In-Reply-To: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just because it's "authenticated" doesn't mean you have "permission".
What are the contents of your server's export file, and the umode of
the target /data0/tmp directory? And btw, what types/versions are
your client and server?

Tom.

At 07:32 AM 9/26/2008, howard chen wrote:
>Hi,
>
>I have a sudden problem when my server reboot and mount to a NFS
>failed, so I neeed to mount
>by hand. (But it was okay before...)
>
>Error:
>
>mount: trying xxxx prog 100003 vers 3 prot udp port 2049
>mount: trying xxxx prog 100005 vers 3 prot udp port 891
>mount: xxxx:/data0/tmp failed, reason given by server: Permission
>denied
>
>Many pages in the web said it is related to the hostname and ip
>mapping, which made permission issues,
>but in my NFS server,  I see the permission is ok:
>
>(/var/log/message)
>
>authenticated mount request from xxxx for yyyy...
>
>Any idea for this funny problem?
>

