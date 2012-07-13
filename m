Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020Ab2GMPpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jul 2012 11:45:01 -0400
Date: Fri, 13 Jul 2012 11:45:00 -0400
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120713154500.GB32660@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337983796-26476-1-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 25, 2012 at 06:09:52PM -0400, Simo Sorce wrote:
> This patchset implements a new upcall mechanism that uses the sunrpc
> client to talk to gssproxy[1], a new userspace daemon that handles gssapi
> operations on behalf of other processes on the system.
> 
> The main driver for this new mechanism is to overcome limitations with
> the current daemon and upcall. The current code cannot handle tickets
> larger than approximatively 2k and cannot handle sending back large user
> credential sets to the kernel.
> 
> These patches have been tested against the development version of gssproxy
> tagged as kernel_v0.1 in the master repo[2].
> 
> I have tested walking into mountpoints using tickets artificially pumped
> up to 64k and the user is properly authorized, after the accept_se_context
> call is performed through the new upcall mechanism and gssproxy.
> 
> The gssproxy has the potential of handling also init_sec_context calls,
> but at the moment the only targeted system is nfsd.

Something I forgot to ask about.  (Or I did ask and forgot to take notes
on the answer!): how is gssproxy doing the principal->(uid, gid's)
mapping?

(svcgssd uses libnfsidmap--which I don't particularly like, but if
gssproxy is doing something different then we need to figure out how the
transition will work).

--b.
