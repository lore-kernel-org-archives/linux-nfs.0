Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27209 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcEWRWJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2016 13:22:09 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1464020307-8806-1-git-send-email-steved@redhat.com>
Date: Mon, 23 May 2016 13:22:02 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 23, 2016, at 12:18 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> I have a customer that requested the domain used
> to do the ID mapping be available via DNS SVR 
> record. I didn't think was that bad of an idea.

Solaris NFS peers look for a TXT record. This
facility has been around for a decade or more.

;; NFSv4 domain (for idmapping).  See Sun doc 819-1634 and
;;      http://tools.ietf.org/html/draft-mesta-nfsv4-domain-01.html
_nfsv4idmapdomain               IN TXT          "oracle.com"

But there's no standard in this area. mesta-nfsv4-domain
was a personal I-D that never advanced. I brought it
up again in Orlando, and the WG decided to table it.

At the time it was decided that the right course of
action was for the NFSv4 idmapping domain to be set
based on security realm or other criteria. There was
no interest in involving DNS at all.


> IPA and FedFS use SRV records which seem to work out
> pretty well. This patch is heavily based on the 
> FedFS code. ;-) 
> 
> My only question is do we want libnfsidmap to be
> dependent on the resolver library. There has been
> some talk about moving libnfsidmap into nfs-utils
> which means nfs-utils would be dependent the
> resolver library. 
> 
> Note, this is not complete. If we are going to do
> this I have to document it somehow, either in 
> the man page or idmap.conf or both.
> 
> Just looking for thoughts... good/bad idea??

If you really do want to go down this path, I
think Linux should follow the existing de facto
standard (TXT), not invent its own. Maybe also
check how SMB does this.

Involving a published DNS record format should
require standards action. But I was discouraged
from pursuing this further.

I think it's important to ask in what cases
will the ID mapping domain be different than
the system's DNS domain name, and is there a
preferable mechanism for determining the ID
mapping domain in those cases? Knowing more
about how your customer plans to use this
feature would help us discuss this more fully.

I've also proposed the ability to set the ID
mapping domain via a command line tool like
nfsidmap. But I never got past the difficulties
of parsing and updating the /etc/idmapd.conf
file. It makes sense to add an API to libnfsidmap
for setting the system's ID mapping domain name.

How would "nfsidmap -d" work if the ID mapping
domain was set via DNS?

Would the DNS-derived ID domain name be cached
somewhere?

> Steve Dickson (1):
>  libnfsidmap: Query DNS for the NFSv4 ID domain
> 
> configure.ac  |  1 +
> libnfsidmap.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 2 files changed, 89 insertions(+), 1 deletion(-)
> 
> -- 
> 2.5.0

--
Chuck Lever



