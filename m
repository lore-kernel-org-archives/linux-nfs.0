Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:14710 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbcD2O1J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2016 10:27:09 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Steve Dickson <SteveD@redhat.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
Date: Fri, 29 Apr 2016 14:27:06 +0000
Message-ID: <1461940027554.14958@netapp.com>
References: <1461771407-16423-1-git-send-email-andros@netapp.com>,<57236BB6.50103@RedHat.com>
In-Reply-To: <57236BB6.50103@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve

Yes, if we decide to keep the multiple hostname option, then a man page update is required. I don't think we have a consensus on using the multiple hostname mount option as a CLI to express session trunking addresses. Chuck Lever made some good points around not using multiple hostnames:

---- From Chuck: ----
- client admins can specify arbitrary hostnames on the command line; hostnames
for instance that correspond to some other server.

- network conditions can change at anytime, making
the original set of trunks lop-sided, or some trunks
may become unreachable. What if the server reboots
with new i/f's or with one or more removed? The
client would likely have to remount in these cases
to adapt to network configuration changes.

- multiple hostnames could be nailed into
/etc/fstab on potentially hundreds of clients. When
server or network configuration changes, there would
have to be a manual change on all these clients.
----------

What do you think? Should we keep the multiple hostname CLI as one method of expressing session trunking addresses?

-->Andy
________________________________________
From: Steve Dickson <SteveD@redhat.com>
Sent: Friday, April 29, 2016 10:12 AM
To: Adamson, Andy; trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2

Hey Andy,

On 04/27/2016 11:36 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
>
> RFC patchset
>
> Main question: Do we want to use multiple hostnames on the mount command to
>    communicate the NFSv4.1 session trunking addresses, or only use (yet
>    to be coded) fs_locations_info?
>
> The multiple hostnames on the mount command are added to a new multiaddr
> option and passed to the kernel for consumption.
Should there be some type of man page update talking about his new option
and how to used it?

steved.

>
> This code requires the kernel "Version 3 NFSV4.1,2 session trunking"
> patch set.
>
> If we want to keep the multiple hostnames on the mount command method of
> expressing NFSv4.1 session trunking addresses, we should fix this:
>
> - v3 mounts with multiple hostnames succeeds but adds an mtab dev entry that
> omits the ":/<exported dir> and so prints a warning at umount.
> - need to update the manpage
>
> -->Andy
>
> Andy Adamson (2):
>   NFS parse NFSv4 multiple hostnames
>   NFS add multiaddr mount option
>
>  utils/mount/parse_dev.c | 30 +++++++++++++++--------
>  utils/mount/parse_dev.h |  2 +-
>  utils/mount/stropts.c   | 63 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  utils/mount/utils.c     |  2 +-
>  4 files changed, 84 insertions(+), 13 deletions(-)
>