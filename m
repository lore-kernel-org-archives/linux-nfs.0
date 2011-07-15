Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:15366 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1GOLGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 07:06:48 -0400
Subject: [PATCH/RFC 0/10] enable SKB paged fragment lifetime visibility
From: Ian Campbell <Ian.Campbell@citrix.com>
To: <netdev@vger.kernel.org>
CC: <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Jul 2011 12:06:46 +0100
Message-ID: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

The following is my attempt to allow entities which inject pages into
the networking stack to receive a notification when the stack has really
finished with those pages (i.e. including retransmissions, clones,
pull-ups etc) and not just when the original skb is finished with. It
implements something broadly along the lines of what was described in
[0].

The series is a proof-of-concept but I have used it to implement a fix
for the NFS issue which I described in [1] (for O_DIRECT writes only, I
presume non O_DIRECT writes would benefit from the same treatment), by
delaying completion of the write() until the pages are no longer
referenced by the network stack (which can happen due to retransmissions
or cloning). I expect that other block and filesystem users of the
network subsystem (e.g. iSCSI) would also benefit from this
functionality since they will suffer from the same class of issue.

Although I've not rebased onto it yet (this series is on 3.0-rc5) I also
expect it would be possible to remove the need to copy on clone which
was recently added to support the SKBTX_DEV_ZEROCOPY stuff by Shirley
Ma. I also expect that this functionality will be useful in my attempts
to add foreign page mapping to Xen's netback (per [2]).

Lastly I think the AF_PACKET mmap'd TX ring completion could also
benefit, although I wasn't able to cause an actual failure in that case,
it seems like cloning of skb's would cause pages which are still
referenced by the stack to be released back to userspace.

In order to do this I have introduced an API to manipulate an SKBs paged
fragments (which unfortunately necessitated changing each driver),
including an explicit fragment ref and unref API to replace the direct
use of get/put_page. Using those I was then able to add an optional
extra layer of reference counting to the paged fragments which can be
used by the creator of the fragment to receive a callback at the time
the page would normally be freed.

What is the general feeling regarding this approach?

The series has been built allmodconfig on x86_64 so I have likely missed
some arch-specific drivers etc. I'll take care of that in future
postings, as well as addressing the issues mentioned in some of the
commit messages.

Ian.

[0] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[1] http://marc.info/?l=linux-nfs&m=122424132729720&w=2
[2] http://marc.info/?l=linux-netdev&m=130893020922848&w=2



