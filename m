Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:44361
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932256Ab0HCTDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 15:03:36 -0400
Date: Tue, 3 Aug 2010 21:03:27 +0200
From: Michael Guntsche <mike@it-loops.com>
To: linux-nfs@vger.kernel.org
Subject: Kerberos auth Problem with nfs3/4
Message-ID: <20100803190327.GA12391@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Some more news,

I tried mounting the same export from a macosx client and it succeeded.
There was a difference though when looking at the rpc.svcgssd output

rpc.svcgssd -vvf:
=================
leaving poll
handling null request
sname = maru@COMSICK.AT
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1280897678 (35627 from now), clnt: <null>, uid: 1000, gid: 1000, num aux grps: 8:
  (   1) 1000
  (   2) 20
  (   3) 24
  (   4) 25
  (   5) 29
  (   6) 44
  (   7) 46
  (   8) 118
sending null reply
finished handling null request
entering poll
leaving poll
handling null request
sname = maru@COMSICK.AT
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1280897678 (35627 from now), clnt: <null>, uid: 1000, gid: 1000, num aux grps: 8:
  (   1) 1000
  (   2) 20
  (   3) 24
  (   4) 25
  (   5) 29
  (   6) 44
  (   7) 46
  (   8) 118
sending null reply
finished handling null request

As you can see it uses a different sname and there are two requests, while I only see one with the linux client. Of course uid and gid are different too.

Kind regards,
Michael
