Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:34558 "EHLO
        elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752218AbeBIU2d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Feb 2018 15:28:33 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@redhat.com>,
        "'Lu Xinyu'" <luxy.fnst@cn.fujitsu.com>
Cc: <linux-nfs@vger.kernel.org>
References: <918ad604-2365-b612-56a2-8d88a29f77ff@cn.fujitsu.com> <20180209144942.GB30030@parsley.fieldses.org>
In-Reply-To: <20180209144942.GB30030@parsley.fieldses.org>
Subject: RE: Questions about pynfs:testLargeData-WRT5
Date: Fri, 9 Feb 2018 09:53:09 -0800
Message-ID: <021c01d3a1ce$d9919cd0$8cb4d670$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, Feb 09, 2018 at 09:27:00AM +0800, Lu Xinyu wrote:
> > I ran pynfs on the RHEL7.4GA with different
> > kernels(3.10.0-830.el7,4.15). The testLargeData:WRT5 failed with
> > broken pipe. I investigated pynfs code and got the following
> > questions.
> >
> > 1.The intent of WRT5 To check whether the server could handle a
> > too-large value over NFSSVC_MAXBLKSIZE.
> >
> > 2.The expected procedure when test gets passed The server could write
> > down the oversize data successfully sent by client and return NFS4_OK.
> > Then, client could read back the data from server.
> 
> Yes, that test is definitely wrong.  It might happen to work on servers
that
> support larger IO size, but the Linux server doesn't.  And, anyway, it's
perfectly
> legal for a server to only support lower read/write size.

The test does happen to pass on Ganesha.

> So, the test needs check the server's advertised maximum read and write
sizes,
> and then either:
> 
> 	1) use that maximum size, and expect success, or
> 	2) use a larger size and expect some sort of error.
> 
> > (Actually, the test failed with broken pipe and did not return packet
> > information.)
> >
> > 3.The nfs server's standrd procedure of handling oversize data It
> > seems that the related error is not defined in the RFC3530. Whether
> > the server should return any NFSERR before ceasing receving ?
> 
> I'm not sure if the RFC's specify the behavior here.  I'll go do some
research.  I
> have a feeling they don't.  In that case I think the best option will be
1) above.

That's probably the right thing to do.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

