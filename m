Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206Ab1ITUM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 16:12:56 -0400
Date: Tue, 20 Sep 2011 16:12:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan-Marek Glogowski <glogow@fbihome.de>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: Problem useing groups containing spaces in NFSv4
Message-ID: <20110920201255.GC15273@fieldses.org>
References: <alpine.DEB.2.02.1108262018320.28308@users.fbihome.de>
 <20110920133016.GF1800@fieldses.org>
 <alpine.DEB.2.02.1109202031250.26882@users.fbihome.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1109202031250.26882@users.fbihome.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 20, 2011 at 09:46:46PM +0200, Jan-Marek Glogowski wrote:
> On Tue, 20 Sep 2011, J. Bruce Fields wrote:
> >Agreed that if a name couldn't be mapped, we do still want to respond to
> >the kernel to tell it that, so that it can handle the problem and
> >continue.  I think we do that correctly.
> >
> >I think this case is a little different--if we have a failure here in
> >the decoding, it means that there's a bug somewhere, either in the
> >kernel's encoding or our parsing.  In that case there's no real recourse
> >other than logging an error and hoping a helpful user tells us about it!
> 
> I have no knowledge of the NFS protocol or NFS error handling, but
> from my POV, I would expect something like a NFS server error
> telling the client, that the server can't comply (probably even
> including the reason "I don't know your group") - and EIO from the
> chgrp syscall.
> 
> At the end this boils down to:
> 
> 1. Wait forever until the server recovers or the user aborts manually or

No, that's not what happens, look at the code.  The "I don't know your
group" case is handled near the end of utils/idmapd/idmapd.c:nfsdcb():

		/* Note that we don't want to write the id if the mapping
                 * failed; instead, by leaving it off, we write a negative
                 * cache entry which will result in an error returned to
                 * the client.  We don't want a chown or setacl referring
                 * to an unknown user to result in giving permissions to
                 * "nobody"! */
                if (im.im_status == IDMAP_STATUS_SUCCESS) {
                        /* ID */
                        snprintf(buf1, sizeof(buf1), "%u", im.im_id);
                        addfield(&bp, &bsiz, buf1);

                }

The error you found is of a completely different type: it's not "the
kernel just asked me to map a name that I don't know", it's "the kernel
made a request which appears to me to be nonsense".

In *that* case, there's a bug, and all we can do is fix it.

--b.

> 2. Tell the user about the current server problem and abort the request.
> 
> And that's were we have the soft and hard mount options - I just
> forgot, that the default is hard and then this behaviour is expected
> :-)
> 
> Jan-Marek
