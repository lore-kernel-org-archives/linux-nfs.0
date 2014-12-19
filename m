Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:41486 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaLSPLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 10:11:14 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so855990ier.13
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 07:11:14 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 19 Dec 2014 10:11:13 -0500
Message-ID: <CAN-5tyErUrXJ+XA6tcGMAtVX7CJaahV6TzzGR1a=E_sXzp9i3g@mail.gmail.com>
Subject: question about code in delegation.c
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I have a question about a patch you committed 57bfa891 and
specifically about the comment that's in the code saying "deal with
the broken servers that hand out two delegations for the same file".
Why is this considered to be broken?

The situation I'm experiencing has the following flow:
1. client opens a file and gets a write delegation.
2. this file is then closed, it's subsequently locally opened for
write (no open on the wire). delegation stateid is also used for write
operations seen on the wire. all is good.
3. then client (on the wire) sends an open for read. first i'm not
sure why this is not local. but let's say the client is allowed to do
so.
4. the server knows this client has a write delegation for this file
so it replies to the open with the write delegation.
5. then code in "nfs_node_set_delegation" sees that it's the same
delegation and ends up returning "it". however from the server's point
of you, it considers the client returning the one delegation it gave
out.
6. the client proceeds to use the delegation stateid which causes the
server to send BAD_SESSIONID which leads the client to initiate state
recovery and mark it's locks lost and return EIO.

(a) it seems like the open for read shouldn't have gone on the wire to
begin with, but
(b) if there are cases when we do want to send an open even if we hold
a delegation, then shouldn't we just ignore if we receive the same
delegation that already hold?

Thank you.
