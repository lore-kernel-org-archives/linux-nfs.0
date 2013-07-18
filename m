Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14214 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758877Ab3GROql convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 10:46:41 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: SP4_MACH_CRED: v4 proc -> opcodes mapping
Date: Thu, 18 Jul 2013 14:46:39 +0000
Message-ID: <7EC48508-29F6-42DF-9BBA-F90A5CA1A47C@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

I have a mostly functional client-side implementation of SP4_MACH_CRED! It still needs a lot of cleanup and testing.

I have one style issue that I want to run by the list before I post a patchset:

So, SP4_MACH_CRED negotiates two bitmaps in the EXCHANGE_ID (one "enforce", one "allow") for state protection. These bitmaps are indexed by the NFSv4 operation number.  The state protect check must happen in the nfs4proc.c layer (or before), right before we call rpc_call_sync or equivalent, so that it can select the right cred and rpc_client.

Here's the problem: we don't know what operations (opcodes) are actually in a compound until the XDR encode callback is called.  The rpc_procinfo array doesn't have this mapping - in fact, it only lives in the xdr encode layer.

One approach is to immediately translate the opcode bitmaps to "nfs4 procedure index" bitmaps, indexing into the rpc_procinfo array.  This would mean there is a second mapping of NFSv4 procedure -> opcodes that must be updated when an XDR encode callback is changed.

Another approach would be to add a callback to the XDR api so we could "ask" it if an NFSv4 procedure contains any of the opcodes in a bitmap. The nice thing about this approach is that the mapping of procedure to opcodes within will live right next to the XDR encode callback and make it obvious that both need to be changed together.

I suppose I'm leaning toward a combination of both of these approaches - keep the mapping in XDR-land and translate the bitmaps immediately on negation for fast lookups during normal operation.

Comments? Am I missing something?

-dros