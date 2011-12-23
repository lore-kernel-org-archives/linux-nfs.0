Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40836 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771Ab1LWLjX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 06:39:23 -0500
Received: by mail-ey0-f174.google.com with SMTP id d14so2678264eaa.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 03:39:22 -0800 (PST)
MIME-Version: 1.0
Reply-To: vishal.thanki@gmail.com
In-Reply-To: <CAC3a_SD609RTOaCzh4g+Ukng8Z7+oQn+r-vEBMPDPMU7nxPWRA@mail.gmail.com>
References: <CAC3a_SD609RTOaCzh4g+Ukng8Z7+oQn+r-vEBMPDPMU7nxPWRA@mail.gmail.com>
From: Vishal Thanki <vishalthanki@gmail.com>
Date: Fri, 23 Dec 2011 17:09:01 +0530
Message-ID: <CAC3a_SBcMYRz-dQGLFzqBW5+_gB9P_GuVqiXtG9jGgtmr5Rj7Q@mail.gmail.com>
Subject: Re: LAYOUTGET failure handling
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 23, 2011 at 4:51 PM, Vishal Thanki <vishalthanki@gmail.com> wrote:
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
> I am using RHEL6.1 (with pNFS patch for kernel 2.6.32 applied) on
> server, and client is RHEL6.1 stock kernel.
>
> I am sorry if this is not the appropriate forum for such kind of
> questions, and pardon my ignorance/lack of knowledge in the domain.
>
> Thanks,
> Vishal

I noticed that "send_layoutget" function is invoked from
pnfs_update_layout. All the callers of pnfs_update_layout seem to
ignore the return value (struct pnfs_layout_segment *). The callers of
this functions are following (if i am not missing any other places):

nfs_write_begin,
nfs_readpage_async,
nfs_readpages

Vishal
