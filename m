Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41691 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933442Ab2HXUv2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Aug 2012 16:51:28 -0400
Received: by eekc1 with SMTP id c1so359874eek.19
        for <linux-nfs@vger.kernel.org>; Fri, 24 Aug 2012 13:51:27 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 24 Aug 2012 22:51:26 +0200
Message-ID: <CALS3df3f-H=UKP2kARY4p0qtK2VaEMVQgZM-omBU-LJZejOT8w@mail.gmail.com>
Subject: Unprivileged port and ERR_PERM
From: Pawel Dziepak <pdziepak@quarnos.org>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have noticed that when a client issues a request from insecure port
(involving an object from export that does not allow that) nfsd
returns ERR_PERM. This does not seem to conform to the either NFS or
RPC specification. First of all, NFS4 specification states that only
CREATE, OPEN and SETATTR operations may return ERR_PERM, in situation
when:

"Not owner. The operation was not allowed
because the caller is either not a privileged
user (root) or not the owner of the target of
the operation."

Moreover, definition of ERR_ACCESS points out the difference between
these two error codes.

"Contrast this with NFS4ERR_PERM,
which restricts itself to owner or privileged
user permission failures."

I believe that ERR_ACCESS is more suitable error code when access is
denied due to insecure port, at least no client will get unexpected
ERR_PERM.
However, rejecting RPC request and setting rejection reason to
AUTH_TOOWEAK seems to be the best solution. In appendix A RPC version
2 specification suggests that using privileged transport addresses may
be a part of client authentication.

"The authentication provided by this scheme can be considered
legitimate only when applications using this scheme and the network
can be secured externally, and privileged transport addresses are
used for the communicating end-points (an example of this is the use
of privileged TCP/UDP ports in UNIX systems -- note that not all
systems enforce privileged transport address mechanisms)."

Hence, AUTH_TOOWEAK would clearly state that access was denied due to
authentication problem, use of insecure port in this case. IIRC this
is the way nfsportmon behaves.

Pawe³ Dziepak
