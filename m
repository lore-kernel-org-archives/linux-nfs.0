Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55285 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335Ab0JRQVo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 12:21:44 -0400
Received: by fxm4 with SMTP id 4so766306fxm.19
        for <linux-nfs@vger.kernel.org>; Mon, 18 Oct 2010 09:21:43 -0700 (PDT)
In-Reply-To: <20101018164414.ec860360.ctpm@ist.utl.pt>
References: <1287362142-sup-777@au1.ibm.com>
	<20101018101059.574b715a@corrin.poochiereds.net>
	<20101018154811.768baeb5.ctpm@ist.utl.pt>
	<20101018155344.6e50dbb9.ctpm@ist.utl.pt>
	<20101018110138.5f5001eb@corrin.poochiereds.net>
	<20101018164414.ec860360.ctpm@ist.utl.pt>
Date: Mon, 18 Oct 2010 12:21:43 -0400
Message-ID: <AANLkTi=FauBoB4R=WCudvX8fLmVU1tGfKQkwpKaQPPLg@mail.gmail.com>
Subject: Re: NFS sillyrename side effect
From: Lyle Seaman <lyleseaman@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You would need to do the state recovery before or during the fsck
(which would require the local filesystem to have some loose
integration with the network protocol).

Also, re the original issue, can't the client do a silly rename of the
directory if it contains only .nfs files during rmdir?

> Suppose though that the server crashes and reboots. When it comes back
>> up, fsck figures out that the file has been unlinked and frees the
>> blocks on the disk. Now you can't reclaim the state on the open file.
