Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og108.obsmtp.com ([64.18.1.21]:50634 "HELO
	exprod6og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752947Ab0IHFeq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Sep 2010 01:34:46 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Query regarding NFS packet capture at application layer - umount operation.
Date: Wed, 8 Sep 2010 01:34:42 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D198A3F@nsmail.netscout.com>
In-Reply-To: <20100907173118.GC13022@fieldses.org>
References: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com> <4C85EE24.9070007@cn.fujitsu.com> <D3F292ADF945FB49B35E96C94C2061B90D198455@nsmail.netscout.com> <20100907131902.3f22b411@tlielax.poochiereds.net> <20100907173118.GC13022@fieldses.org>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Jeff Layton" <jlayton@redhat.com>
Cc: "Bian Naimeng" <biannm@cn.fujitsu.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Tuesday, September 07, 2010 11:01 PM
> To: Jeff Layton
> Cc: Tayade, Nilesh; Bian Naimeng; linux-nfs@vger.kernel.org
> Subject: Re: Query regarding NFS packet capture at application layer
> - umount operation.
> 


> > > I am using NFSv3. (Sorry, I forgot to mention it in first email
> - so I
> > > have replied to my original email with capture file).
> > >
> >
> > I'm fairly sure that's still handled by the userspace piece. Do
> you
> > have a /sbin/umount.nfs? If not, that may be why.
> 
> Or if you're only capturing traffic to port 2049, that would also
> explain why you don't see anything.  (NFSv2/v3 mount/umount use
> different protocol.)
> 
> --b.

Thanks for the pointers. That appears to be the case. I could see the
header of MOUNT in the packet when I mounted/umounted the node. I
thought there will be the NFS header instead.

--
Thanks,
Nilesh



