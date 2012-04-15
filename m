Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43065 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab2DOT1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Apr 2012 15:27:21 -0400
Date: Sun, 15 Apr 2012 15:27:14 -0400
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Jeff Layton <jlayton@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, pstaubach@exagrid.com, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120415192714.GA3842@fieldses.org>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
 <20120413150518.GA1987@us.ibm.com>
 <20120413114236.0e557e01@tlielax.poochiereds.net>
 <4F8B1B7B.3040304@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F8B1B7B.3040304@itwm.fraunhofer.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 15, 2012 at 09:03:23PM +0200, Bernd Schubert wrote:
> On 04/13/2012 05:42 PM, Jeff Layton wrote:
> > (note: please don't trim the CC list!)
> > 
> > Indefinitely does make some sense (as Peter articulated in his original
> > set). It's possible you could race several times in a row, or a server
> > misconfiguration or something has happened and you have a transient
> > error that will eventually recover. His assertion was that any limit on
> > the number of retries is by definition wrong. For NFS, a fatal signal
> > ought to interrupt things as well, so retrying indefinitely has some
> > appeal there.
> > 
> > OTOH, we do have to contend with filesystems that might return ESTALE
> > persistently for other reasons and that might not respond to signals.
> > Miklos pointed out that some FUSE fs' do this in his review of Peter's
> > set.
> > 
> > As a purely defensive coding measure, limiting the number of retries to
> > something finite makes sense. If we're going to do that though, I'd
> > probably recommend that we set the number of retries be something
> > higher just so that this is more resilient in the face of multiple
> > races. Those other fs' might "spin" a bit in that case but it is an
> > error condition and IMO resiliency trumps performance -- at least in
>  this case.
> 
> I am definitely voting against an infinite number of retries. I'm
> working on FhGFS, which supports distributed meta data servers. So when
> a file is moved around between directories, its file handle, which
> contains the meta-data target id might become invalid.  As NFSv3 is
> stateless we cannot inform the client about that and must return ESTALE
> then.

Note we're not talking about retrying the operation that returned ESTALE
with the same filehandle--probably any server would return ESTALE again
in that case.

We're talking about re-looking up the path (in the case where we're
implementing a system call that takes a path as an argument), and then
retrying the operation with the newly looked-up filehandle.

--b.

> NFSv4 is better, but I'm not sure how well invalidating a file
> handle works. So retrying once on ESTALE might be a good idea, but
> retrying forever is not.
> Also, what about asymmetric HA servers? I believe to remember that also
> resulted in ESTALE. So for example server1 exports /home and /scratch,
> but on failure server2 can only take over /home and denies access to
> /scratch.
> 
> 
> Thanks,
> Bernd
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
