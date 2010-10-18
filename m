Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.ist.utl.pt ([193.136.128.22]:55900 "EHLO smtp2.ist.utl.pt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757130Ab0JRRAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 13:00:20 -0400
Date: Mon, 18 Oct 2010 18:00:18 +0100
From: =?UTF-8?B?Q2zDoXVkaW8=?= Martins <ctpm@ist.utl.pt>
To: Lyle Seaman <lyleseaman@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: NFS sillyrename side effect
Message-Id: <20101018180018.9d730e1f.ctpm@ist.utl.pt>
In-Reply-To: <AANLkTi=FauBoB4R=WCudvX8fLmVU1tGfKQkwpKaQPPLg@mail.gmail.com>
References: <1287362142-sup-777@au1.ibm.com>
	<20101018101059.574b715a@corrin.poochiereds.net>
	<20101018154811.768baeb5.ctpm@ist.utl.pt>
	<20101018155344.6e50dbb9.ctpm@ist.utl.pt>
	<20101018110138.5f5001eb@corrin.poochiereds.net>
	<20101018164414.ec860360.ctpm@ist.utl.pt>
	<AANLkTi=FauBoB4R=WCudvX8fLmVU1tGfKQkwpKaQPPLg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mon, 18 Oct 2010 12:21:43 -0400 Lyle Seaman <lyleseaman@gmail.com> wrote:
> You would need to do the state recovery before or during the fsck
> (which would require the local filesystem to have some loose
> integration with the network protocol).
> 
> Also, re the original issue, can't the client do a silly rename of the
> directory if it contains only .nfs files during rmdir?
> 

 I think the problem is that would be racy. You have no guarantee that
other clients won't create files on that directory between the time you
check the directory and the time you'd silly-rename it, so you would
end up "deleting" directories which are not "empty".

Best regards

Cláudio

