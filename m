Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218AbcD2OqX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 10:46:23 -0400
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
To: "Adamson, Andy" <William.Adamson@netapp.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>
References: <1461771407-16423-1-git-send-email-andros@netapp.com>
 <57236BB6.50103@RedHat.com> <1461940027554.14958@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <572373BE.4000201@RedHat.com>
Date: Fri, 29 Apr 2016 10:46:22 -0400
MIME-Version: 1.0
In-Reply-To: <1461940027554.14958@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/29/2016 10:27 AM, Adamson, Andy wrote:
> Hi Steve
> 
> Yes, if we decide to keep the multiple hostname option, then a man page update is required. I don't think we have a consensus on using the multiple hostname mount option as a CLI to express session trunking addresses. Chuck Lever made some good points around not using multiple hostnames:
> 
> ---- From Chuck: ----
> - client admins can specify arbitrary hostnames on the command line; hostnames
> for instance that correspond to some other server.
> 
> - network conditions can change at anytime, making
> the original set of trunks lop-sided, or some trunks
> may become unreachable. What if the server reboots
> with new i/f's or with one or more removed? The
> client would likely have to remount in these cases
> to adapt to network configuration changes.
> 
> - multiple hostnames could be nailed into
> /etc/fstab on potentially hundreds of clients. When
> server or network configuration changes, there would
> have to be a manual change on all these clients.
> ----------
> 
> What do you think? Should we keep the multiple hostname CLI as one method of expressing session trunking addresses?
I would think so... Just to put some context into this... We are talking
about:

mount -o v4.1 server1,server2,server3:/export /mnt

server1 would be tried, if that fails server2 would be tried?

steved.
