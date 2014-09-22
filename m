Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754914AbaIVUA6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 16:00:58 -0400
Date: Mon, 22 Sep 2014 16:00:50 -0400
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140922160050.0b85f044@willson.usersys.redhat.com>
In-Reply-To: <54207E4A.7010300@RedHat.com>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922194057.GE26763@fieldses.org>
	<20140922154642.779189c8@willson.usersys.redhat.com>
	<54207E4A.7010300@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Sep 2014 15:53:46 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 09/22/2014 03:46 PM, Simo Sorce wrote:
> > On Mon, 22 Sep 2014 15:40:57 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> >> On Mon, Sep 22, 2014 at 03:20:07PM -0400, Steve Dickson wrote:
> >>> Added the gssproxy.service to both the Wants= and
> >>> Atfers= lines, before the rpc-svcgssd.service. There
> >>> are  ConditionPathExists= lines in the rpc-svcgssd.service
> >>> unit which will stop the rpc.svcgssd daemon from
> >>> starting when the gssproxy daemon is already running.
> >>
> >> That should read "when the kernel supports gssproxy", not "when the
> >> gssproxy daemon is already running."
> > 
> > Actually the language is currently correct but it is another bug,
> > the systemd/rpc-svcgssd.service file still includes
> > "ConditionPathExists=|!/run/gssproxy.pid"
> > This line should be removed in this patch.
> 
> I left that on purpose because isn't that ConditionPathExists
> seeing if /run/gssproxy.pid exists and if it does 
> it means gssproxy is already running so rpc.svcgssd 
> should not start?

No.
First of all the fact gss-proxy is running does not mean it is
serving nfsd necessarily, it may be running on an older kernel where it
servers apache or some other process (remember gssproxy is not just
for nfsd).
Second you already have
"ConditionPathExists=|!/proc/net/rpc/use-gss-proxy" which is the
correct trigger to decide which of the two to use.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
