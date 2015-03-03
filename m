Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757641AbbCCVo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 16:44:59 -0500
Message-ID: <54F62B59.2060502@RedHat.com>
Date: Tue, 03 Mar 2015 16:44:57 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH 2/2] systemd: Relax dependencies of services
References: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com> <1425403690-23847-3-git-send-email-martin.pitt@ubuntu.com> <20150303180809.GJ3058@in.waw.pl> <20150303201214.GA3473@piware.de>
In-Reply-To: <20150303201214.GA3473@piware.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/03/2015 03:12 PM, Martin Pitt wrote:
> Hello all,
> 
> Zbigniew Jędrzejewski-Szmek [2015-03-03 19:08 +0100]:
>> Are you sure that all of those nfs daemons do not require
>> sockets.target and other stuff provided by basic.target to be ready?
> 
> The corresponding upstart jobs trigger on virtual file systems (/sys,
> etc.) and rpcbind, and we've used them for years. Also, NFS does not
> yet use socket activation, or talks to other services on sockets
> (except for rpcbind), so we don't need sockets.target either.  The
> other dependencies (some network.target, some nss-lookup.target, etc.)
> are already specified explicitly. So I'm quite sure.
You are correct. rpcbind is the only service we have that uses socket
activation, which I don't think works very well... 

Just last week I notice if you reboot a vm and the first command 
you type is rpcinfo -p. That command will time out trying to talk
with rpcbind. After the timeout everything works fine... 

I thought I opened a bz but I can't seem to find it.

steved.

> 
> That said, there's of course always a nonzero chance that this breaks
> in a case which I haven't tested. In particular, I didn't test
> kerberos/gssd, I'd appreciate if someone who has a real-world setup
> with that could give this a spin.
> 
> Thanks,
> 
> Martin
> 
