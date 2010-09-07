From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Subject: RE: Query regarding NFS packet capture at application layer - umount operation.
Date: Tue, 7 Sep 2010 04:02:29 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D198455@nsmail.netscout.com>
References: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com> <4C85EE24.9070007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Bian Naimeng" <biannm@cn.fujitsu.com>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og110.obsmtp.com ([64.18.1.25]:58808 "HELO
	exprod6og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751409Ab0IGICd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 04:02:33 -0400
In-Reply-To: <4C85EE24.9070007@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Bian Naimeng [mailto:biannm@cn.fujitsu.com]
> Sent: Tuesday, September 07, 2010 1:18 PM
> To: Tayade, Nilesh
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Query regarding NFS packet capture at application layer
> - umount operation.
> 


> > Could someone please explain why there is no NFS packet observed
> during
> > an unmount? Also there seems not much information, related to NFS
> mount
> > point being unmounted, in TCP packet. So is there any way to
> detect the
> > unmount operation by hacking such packets?
> >
> 
>   I guess you used NFSv4. NFSv4 umount operation does not send any
> NFS packet.
>   The TCP packets you captured were sent by TCP close procedure,
> because NFS
>   umount operation need close the TCP connection with NFS server.

I am using NFSv3. (Sorry, I forgot to mention it in first email - so I
have replied to my original email with capture file).

> 
> --
> Regards
> Bian Naimeng

