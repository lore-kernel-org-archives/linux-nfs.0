Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og117.obsmtp.com ([64.18.1.39]:36002 "HELO
	exprod6og117.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756495Ab0IBTYh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 15:24:37 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS version4 maximum on-the-wire data size.
Date: Thu, 2 Sep 2010 15:24:30 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D06724D@nsmail.netscout.com>
In-Reply-To: <AADFA0E0-7B1E-49F4-845C-E68488BA8F61@oracle.com>
References: <D3F292ADF945FB49B35E96C94C2061B90CFB48D0@nsmail.netscout.com> <0FDF651C-4620-4872-9ABA-9F8D8FA2192A@oracle.com> <99E0B37F-C9BE-4349-B68A-4364F4EB9C04@oracle.com> <D3F292ADF945FB49B35E96C94C2061B90D066E6F@nsmail.netscout.com> <AADFA0E0-7B1E-49F4-845C-E68488BA8F61@oracle.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Thursday, September 02, 2010 7:43 PM
> To: Tayade, Nilesh
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS version4 maximum on-the-wire data size.
> 

>
> >
> > Also we use 2.6.22 kernel version (it's old, and have no option of
> > changing it) on our Intel boxes. I was just wondering is there any
> > kernel-version Vs. NFS version mapping (I assume it's not, but just
> to
> > be sure about)? I have never seen NFSv2 running on our boxes. I am
> going
> > to write certain applications on top of NFS. So wanted to be sure if
> > NFSv2 should be supported at all (is it so widely used on recent
> > systems, compared to NFSv3/v4)?
> 
> With certain exceptions, applications shouldn't generally be aware of
> what NFS version is in use.  Without knowing more about your
> applications, it's hard to make any more than a very general
statement.

Well, to be specific - I need to deal with packet sniffers (capturing
the NFS packets) and so I need to consider the NFS versions as the
packet contains will differ (different procedure calls, Error codes
etc.). 

> 
> --
> chuck[dot]lever[at]oracle[dot]com
> 
> 

Thanks,
Nilesh
nilesh.tayade@netscout.com



