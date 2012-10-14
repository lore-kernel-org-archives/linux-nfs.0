Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zep00a03.dent.med.uni-muenchen.de ([138.246.161.8]:49644 "HELO
	md.dent.med.uni-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753202Ab2JNUJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 16:09:55 -0400
Date: 14 Oct 2012 22:09:52 +0200
Message-ID: <20121014200952.26230.qmail@md.dent.med.uni-muenchen.de>
From: Wolfram Gloger <wmglo@dent.med.uni-muenchen.de>
To: chuck.lever@oracle.com
CC: linux-nfs@vger.kernel.org
In-reply-to: <6C61B43F-7A32-47E3-B81D-70CD991D9CDF@oracle.com> (message from
	Chuck Lever on Sun, 14 Oct 2012 15:10:29 -0400)
Subject: Re: [PATCH] nfs-utils: Backgrounding mount broken with NFS versions <4
References: <20121012120030.18411.qmail@md.dent.med.uni-muenchen.de> <6AB50360-BADE-4544-85CF-700C63A44FDE@oracle.com> <20121013171856.10814.qmail@md.dent.med.uni-muenchen.de> <F5C4FA78-A467-4306-BC57-0A50D8F0A8A9@oracle.com> <20121013214652.23089.qmail@md.dent.med.uni-muenchen.de> <6C61B43F-7A32-47E3-B81D-70CD991D9CDF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

> Unfortunately there are a rather unimaginable number of use cases for mount.nfs, which is why it is so complicated.  "Extensively" could mean you've tested it for a long time but with just a few use cases.

Admitted, I certainly didn't run an extensive test suite, mainly just
the case in question by simulating server down with a temporary
iptables DROP rule.

> In any event:
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Thanks,
Wolfram.
