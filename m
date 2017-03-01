Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751499AbdCAWIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Mar 2017 17:08:02 -0500
Date: Wed, 1 Mar 2017 17:06:25 -0500
To: Chris Wheeler <grintor@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount NFS 4.1 with session trunking
Message-ID: <20170301220625.GC9545@fieldses.org>
References: <CANqgWRN=GPjpz0OboaQ3MWccJuBKY55mXZFC-r_pPWbvMjj63w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CANqgWRN=GPjpz0OboaQ3MWccJuBKY55mXZFC-r_pPWbvMjj63w@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 01, 2017 at 03:03:30PM -0500, Chris Wheeler wrote:
> I am trying to find some sort of documentation of how to mount a NFS
> 4.1 share using session trunking under Linux. All I can find is
> information of how to do it under VMware ESXI, (in VMware, you simply
> specify multiple IP addresses for your NAS).
> 
> The linux mount man page and nfs man page don't document how to
> specify the IPs you want to use for session trunking, or how to enable
> it.

I believe the interface is still under discussion, so any information
aobut your use case might potentially be useful.

--b.
