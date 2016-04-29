Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:22129 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbcD2PJe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2016 11:09:34 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Steve Dickson <SteveD@redhat.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
Date: Fri, 29 Apr 2016 15:09:31 +0000
Message-ID: <1461942572296.96251@netapp.com>
References: <1461771407-16423-1-git-send-email-andros@netapp.com>
 <57236BB6.50103@RedHat.com>
 <1461940027554.14958@netapp.com>,<572373BE.4000201@RedHat.com>
In-Reply-To: <572373BE.4000201@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> mount -o v4.1 server1,server2,server3:/export /mnt
>
> server1 would be tried, if that fails server2 would be tried?

That is not the way this feature was coded. Currently, server1 is tried. If server1 fails, the mount fails. If server1 succeeds then server2,server3.. are tried as session trunking addrs.

I can of course change this to the behavior you described.

-->Andy
________________________________________
From: Steve Dickson <SteveD@redhat.com>
Sent: Friday, April 29, 2016 10:46 AM
To: Adamson, Andy; trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2

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
