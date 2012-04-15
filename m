Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53249 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006Ab2DOTDd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Apr 2012 15:03:33 -0400
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id CD6102167B
	for <linux-nfs@vger.kernel.org>; Sun, 15 Apr 2012 15:03:32 -0400 (EDT)
Message-ID: <4F8B1B7B.3040304@itwm.fraunhofer.de>
Date: Sun, 15 Apr 2012 21:03:23 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com,
        sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr
 call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <20120413150518.GA1987@us.ibm.com> <20120413114236.0e557e01@tlielax.poochiereds.net>
In-Reply-To: <20120413114236.0e557e01@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/13/2012 05:42 PM, Jeff Layton wrote:
> (note: please don't trim the CC list!)
> 
> Indefinitely does make some sense (as Peter articulated in his original
> set). It's possible you could race several times in a row, or a server
> misconfiguration or something has happened and you have a transient
> error that will eventually recover. His assertion was that any limit on
> the number of retries is by definition wrong. For NFS, a fatal signal
> ought to interrupt things as well, so retrying indefinitely has some
> appeal there.
> 
> OTOH, we do have to contend with filesystems that might return ESTALE
> persistently for other reasons and that might not respond to signals.
> Miklos pointed out that some FUSE fs' do this in his review of Peter's
> set.
> 
> As a purely defensive coding measure, limiting the number of retries to
> something finite makes sense. If we're going to do that though, I'd
> probably recommend that we set the number of retries be something
> higher just so that this is more resilient in the face of multiple
> races. Those other fs' might "spin" a bit in that case but it is an
> error condition and IMO resiliency trumps performance -- at least in
 this case.

I am definitely voting against an infinite number of retries. I'm
working on FhGFS, which supports distributed meta data servers. So when
a file is moved around between directories, its file handle, which
contains the meta-data target id might become invalid. As NFSv3 is
stateless we cannot inform the client about that and must return ESTALE
then. NFSv4 is better, but I'm not sure how well invalidating a file
handle works. So retrying once on ESTALE might be a good idea, but
retrying forever is not.
Also, what about asymmetric HA servers? I believe to remember that also
resulted in ESTALE. So for example server1 exports /home and /scratch,
but on failure server2 can only take over /home and denies access to
/scratch.


Thanks,
Bernd
