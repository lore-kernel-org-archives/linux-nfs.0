Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og104.obsmtp.com ([64.18.1.187]:54746 "HELO
	exprod6og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751677Ab0IBLvX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 07:51:23 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS version4 maximum on-the-wire data size.
Date: Thu, 2 Sep 2010 07:51:19 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D066E6F@nsmail.netscout.com>
In-Reply-To: <99E0B37F-C9BE-4349-B68A-4364F4EB9C04@oracle.com>
References: <D3F292ADF945FB49B35E96C94C2061B90CFB48D0@nsmail.netscout.com> <0FDF651C-4620-4872-9ABA-9F8D8FA2192A@oracle.com> <99E0B37F-C9BE-4349-B68A-4364F4EB9C04@oracle.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Wednesday, September 01, 2010 9:16 PM
> To: Chuck Lever
> Cc: Tayade, Nilesh; linux-nfs@vger.kernel.org
> Subject: Re: NFS version4 maximum on-the-wire data size.
> 
> 
> On Sep 1, 2010, at 11:41 AM, Chuck Lever wrote:
> 
> >
> > On Sep 1, 2010, at 5:39 AM, Tayade, Nilesh wrote:
> >
> >> Hi,
> >>
> >> I am unable to get the exact count for the amount of on-the-wire
data
> >> size that NFSv4 supports.
> >>
> >> I could get exact figures in case of NFSv3
> (http://nfs.sourceforge.net).
> >> It's 60KB when NFSv3 is used over UDP and implementation dependent
in
> >> case it is used over TCP. Any idea about NFSv4 statistics?
> >>
> >> Any pointers would be appreciated.
> >
> > NFSv4 reads and writes can be as large as the maximum payload size
of
> the underlying transport.  NFSv4 does not support UDP, but on TCP, the
> maximum payload size is usually approximately (2 ** 31 - 1) - (RPC
header
> + NFS overhead).
> 
> But you were probably not asking about the theoretical limits of the
> underlying transport.
> 
> The Linux NFS client limits read and write payload size to a megabyte.
> Servers may limit it further.

Thanks for the information. It helps. 

Also we use 2.6.22 kernel version (it's old, and have no option of
changing it) on our Intel boxes. I was just wondering is there any
kernel-version Vs. NFS version mapping (I assume it's not, but just to
be sure about)? I have never seen NFSv2 running on our boxes. I am going
to write certain applications on top of NFS. So wanted to be sure if
NFSv2 should be supported at all (is it so widely used on recent
systems, compared to NFSv3/v4)?

> 
> --
> chuck[dot]lever[at]oracle[dot]com
> 
> 

Thanks,
Nilesh
nilesh.tayade@netscout.com

