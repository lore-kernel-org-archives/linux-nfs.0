Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.ist.utl.pt ([193.136.128.21]:47539 "EHLO smtp1.ist.utl.pt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756481Ab0JROxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 10:53:47 -0400
Date: Mon, 18 Oct 2010 15:53:44 +0100
From: =?UTF-8?B?Q2zDoXVkaW8=?= Martins <ctpm@ist.utl.pt>
To: =?UTF-8?B?Q2zDoXVkaW8=?= Martins <ctpm@ist.utl.pt>
Cc: Jeff Layton <jlayton@redhat.com>, Ian Munsie <imunsie@au1.ibm.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
Message-Id: <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
In-Reply-To: <20101018154811.768baeb5.ctpm@ist.utl.pt>
References: <1287362142-sup-777@au1.ibm.com>
	<20101018101059.574b715a@corrin.poochiereds.net>
	<20101018154811.768baeb5.ctpm@ist.utl.pt>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
> 
>  Section D2 ends with:
> 
> "The NFS version 4 protocol is stateful, and could actually support
> delete-on-last-close. Unfortunately there isn't an easy way to do this
> and remain backwards-compatible with version 2 and 3 accessors."
> 
>  So, theoretically, could one modify the code to selectively disable
> silly rename on a client, when it knows it is talking v4 with the
> server?
> 

 BTW, to clarify, I'm assuming a scenario where the server is
configured to talk v4 only, which I suspect should be common, at least
when you're relying on v4 kerberos security.

Best regards

Cláudio

