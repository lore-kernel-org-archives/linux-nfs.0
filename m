Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58865 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab0JGRN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 13:13:29 -0400
Received: by bwz11 with SMTP id 11so59750bwz.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Oct 2010 10:13:28 -0700 (PDT)
Date: Thu, 7 Oct 2010 13:13:27 -0400
Message-ID: <AANLkTimJXX_sr-fJCfLqLHdAaOPyG9Ry46JbpiNCcvH5@mail.gmail.com>
Subject: pnfs code suggestions
From: Fred Isaman <iisaman@netapp.com>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We are starting to think about wave 2 of the code submission, which
will be LAYOUTRETURN and callback handling.  Current code does not
correctly wait for outstanding LAYOUTGETS on CB_RECALL.  Remembering
that this is for whole file layouts with the forgetful model, my
intent is to work on patches implementing the following.  Let me know
if anyone sees problems with this approach.

On CB_RECALL, set a "barrier" equal to one less than the seqid
embedded in the cb_recall stateid.  Then, instead of waiting on any
outstanding LAYOUTGETs whose seqid is less than the barrier, as
required by the spec, we just drop any LAYOUTGET reply that has a
seqid less than the barrier.  Because we are using the forgetful
model, this is functionally equivalent to waiting, and simpler.
We similarly increase the barrier based on replies from LAYOUTRETURNs.
The major issue I see with this approach is that we have to be very
careful on reset of the stateid to either drain or detect outstanding
LAYOUTGETS.

We will still need to wait on outstanding IO within any existing
layout.  I suggest we use Benny's rpc waitq code, shifting it up into
the submission branch.

Thanks,
Fred
