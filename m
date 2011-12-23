Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:59655 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab1LWO0Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 09:26:16 -0500
Received: by vcbfk14 with SMTP id fk14so7330553vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 06:26:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAC3a_SD609RTOaCzh4g+Ukng8Z7+oQn+r-vEBMPDPMU7nxPWRA@mail.gmail.com>
References: <CAC3a_SD609RTOaCzh4g+Ukng8Z7+oQn+r-vEBMPDPMU7nxPWRA@mail.gmail.com>
Date: Fri, 23 Dec 2011 09:26:15 -0500
Message-ID: <CADnza47Xo2Xt1zXiaAxoNWcwGDGi40a6jUhzFJkKu+oe-7PJGg@mail.gmail.com>
Subject: Re: LAYOUTGET failure handling
From: Fred Isaman <iisaman@netapp.com>
To: vishal.thanki@gmail.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 23, 2011 at 6:21 AM, Vishal Thanki <vishalthanki@gmail.com> wrote:
> Hi,
>
> I am learning NFS (and pNFS) and not much familiar with its
> implementation in Linux kernel. I have a question on the LAYOUTGET
> operation.
>
> I have a pNFS server setup which fakes most of the pNFS operations.
> The "layout_get" implementation simply returns "-ENOENT". I am not
> sure how this should be treated on the pNFS client side. In my
> experiment, I am mounting the pNFS server and trying to read a file
> (using "cat"). On wireshark trace (attached with the mail), I could
> see that LAYOUTGET fails with NFS4ERR_BADLAYOUT error, but afterwards
> I see the READ request from client and it is handled gracefully (and I
> can see the contents of the file). Is this appropriate behavior?
>

Yes.  The client asked for a layout.  The server said no.  So the
client fell back to using standard io to the MDS.
Right now this is basically how the linux client responds to almost all errors.

Fred

> I am using RHEL6.1 (with pNFS patch for kernel 2.6.32 applied) on
> server, and client is RHEL6.1 stock kernel.
>
> I am sorry if this is not the appropriate forum for such kind of
> questions, and pardon my ignorance/lack of knowledge in the domain.
>
> Thanks,
> Vishal
