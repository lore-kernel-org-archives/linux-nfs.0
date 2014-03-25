Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbaCYJeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 05:34:20 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <53308CD4.9020307@RedHat.com>
References: <53308CD4.9020307@RedHat.com> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu>
To: Benjamin Coddington <bcodding@uvm.edu>
Cc: dhowells@redhat.com, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
Date: Tue, 25 Mar 2014 09:34:11 +0000
Message-ID: <21532.1395740051@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> wrote:

> >>> The kernel keyring has a max of ~508 entries on 64-bit systems.
> >>> For installations with more distict users than this limit, create
> >>> a specified number of child keyrings and fill them evenly.

This got fixed recently.

	Commit b2a4df200d570b2c33a57e1ebfa5896e4bc81b69
	Author: David Howells <dhowells@redhat.com>  2013-09-24 10:35:18
	Subject: KEYS: Expand the capacity of a keyring

With that, the capacity is more or less infinite.

David
