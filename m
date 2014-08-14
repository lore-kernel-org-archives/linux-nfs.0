Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbaHNTiB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2014 15:38:01 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christian Seiler" <christian@iwakd.de>
Cc: "Steve Dickson" <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] libnfsidmap: respect Nobody-User/Nobody-Group
Date: Thu, 14 Aug 2014 15:37:54 -0400
Message-ID: <460283FC-40AE-401C-A376-AE4A26EC235B@redhat.com>
In-Reply-To: <603dd17035c81999c99b9020b65d8768@iwakd.de>
References: <1401794264-3975-1-git-send-email-christian@iwakd.de>
 <53EB962C.5000001@RedHat.com> <603dd17035c81999c99b9020b65d8768@iwakd.de>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13 Aug 2014, at 13:45, Christian Seiler wrote:
> My question would be whether there is an easy way to debug this?
> I tried to have a look at the kernel nfs4 client code / the
> interaction with idmap, but I just don't know enough about that
> area of the kernel to really see through the logic.

Do you have access to the server?  You can add -vvv to rpc.idmapd on the
server side to see the upcalls it services from nfsd, and see the
translations.  I don't think nfsd uses nfsidmap (yet).

Also turn up the debugging on rpc.gssd on the client (-vvv) and rpc.svcgssd
on the server - you could be having GSS problems instead of idmapping
problems.

Ben
