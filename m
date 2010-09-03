From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Subject: RE: NFS version4 maximum on-the-wire data size.
Date: Fri, 3 Sep 2010 02:54:37 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D067398@nsmail.netscout.com>
References: <D3F292ADF945FB49B35E96C94C2061B90CFB48D0@nsmail.netscout.com> <0FDF651C-4620-4872-9ABA-9F8D8FA2192A@oracle.com> <99E0B37F-C9BE-4349-B68A-4364F4EB9C04@oracle.com> <D3F292ADF945FB49B35E96C94C2061B90D066E6F@nsmail.netscout.com> <AADFA0E0-7B1E-49F4-845C-E68488BA8F61@oracle.com> <D3F292ADF945FB49B35E96C94C2061B90D06724D@nsmail.netscout.com> <CA6301CC-524C-46C0-BA1A-BB360B6103FB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og108.obsmtp.com ([64.18.1.21]:43662 "HELO
	exprod6og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752603Ab0ICGym convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 02:54:42 -0400
In-Reply-To: <CA6301CC-524C-46C0-BA1A-BB360B6103FB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Friday, September 03, 2010 12:58 AM
> To: Tayade, Nilesh
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS version4 maximum on-the-wire data size.
> 

> >>
> >> With certain exceptions, applications shouldn't generally be aware
of
> >> what NFS version is in use.  Without knowing more about your
> >> applications, it's hard to make any more than a very general
> > statement.
> >
> > Well, to be specific - I need to deal with packet sniffers
(capturing
> > the NFS packets) and so I need to consider the NFS versions as the
> > packet contains will differ (different procedure calls, Error codes
> > etc.).
> 
> NFSv3 and increasingly NFSv4 are in broad use today.  Whether or not
to
> support NFSv2 is dependent on your target customers.  But it's
considered
> a legacy protocol.
> 

Thanks. Appreciate your help.

> --
> chuck[dot]lever[at]oracle[dot]com
> 

Thanks,
Nilesh
nilesh.tayade@netscout.com
 
 

