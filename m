Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792Ab0IGRTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 13:19:16 -0400
Date: Tue, 7 Sep 2010 13:19:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Cc: "Bian Naimeng" <biannm@cn.fujitsu.com>, <linux-nfs@vger.kernel.org>
Subject: Re: Query regarding NFS packet capture at application layer -
 umount operation.
Message-ID: <20100907131902.3f22b411@tlielax.poochiereds.net>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90D198455@nsmail.netscout.com>
References: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com>
	<4C85EE24.9070007@cn.fujitsu.com>
	<D3F292ADF945FB49B35E96C94C2061B90D198455@nsmail.netscout.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 7 Sep 2010 04:02:29 -0400
"Tayade, Nilesh" <Nilesh.Tayade@netscout.com> wrote:

> > -----Original Message-----
> > From: Bian Naimeng [mailto:biannm@cn.fujitsu.com]
> > Sent: Tuesday, September 07, 2010 1:18 PM
> > To: Tayade, Nilesh
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: Query regarding NFS packet capture at application layer
> > - umount operation.
> > 
> 
> 
> > > Could someone please explain why there is no NFS packet observed
> > during
> > > an unmount? Also there seems not much information, related to NFS
> > mount
> > > point being unmounted, in TCP packet. So is there any way to
> > detect the
> > > unmount operation by hacking such packets?
> > >
> > 
> >   I guess you used NFSv4. NFSv4 umount operation does not send any
> > NFS packet.
> >   The TCP packets you captured were sent by TCP close procedure,
> > because NFS
> >   umount operation need close the TCP connection with NFS server.
> 
> I am using NFSv3. (Sorry, I forgot to mention it in first email - so I
> have replied to my original email with capture file).
> 

I'm fairly sure that's still handled by the userspace piece. Do you
have a /sbin/umount.nfs? If not, that may be why.

-- 
Jeff Layton <jlayton@redhat.com>
