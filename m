Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbaCYO3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 10:29:00 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <8D885171-9D19-4E78-BC2F-D5AC906D7A3B@uvm.edu>
References: <8D885171-9D19-4E78-BC2F-D5AC906D7A3B@uvm.edu> <53308CD4.9020307@RedHat.com> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <21532.1395740051@warthog.procyon.org.uk>
To: Benjamin Coddington <bcodding@uvm.edu>
Cc: dhowells@redhat.com, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
Date: Tue, 25 Mar 2014 13:30:45 +0000
Message-ID: <9576.1395754245@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benjamin Coddington <bcodding@uvm.edu> wrote:

> Yep, I'm aware of that - but unless RH backports this fix (which I was told
> is not going to happen) or uses this multiple keyring nfsidmap approach,
> things are going to stay broken in RHEL6.

Backporting the patches to RHEL-6 is a bit tricky as the contents of the key
struct changed as did some of the internal interface functions.  It would be
possible to isolate the changes in the keyring payload struct - but we'd have
to hope no drivers out there access the keyring payload directly.

David
