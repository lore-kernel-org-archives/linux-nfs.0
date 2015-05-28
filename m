Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:56662
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754550AbbE1VLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 17:11:40 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: devel@driverdev.osuosl.org
Cc: kernel-janitors@vger.kernel.org, HPDD-discuss@ml01.01.org,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-wireless@vger.kernel.org
Subject: [PATCH 0/9] drop unneeded goto
Date: Thu, 28 May 2015 23:02:15 +0200
Message-Id: <1432846944-7122-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches drop gotos that jump to a label that is at the next
instruction, in the case that the label is not used elsewhere in the
function.  The complete semantic patch that performs this transformation is
as follows:

// <smpl>
@r@
position p;
identifier l;
@@

if (...) goto l@p;
l:

@script:ocaml s@
p << r.p;
nm;
@@

nm := (List.hd p).current_element

@ok exists@
identifier s.nm,l;
position p != r.p;
@@

nm(...) {
<+... goto l@p; ...+>
}

@depends on !ok@
identifier s.nm;
position r.p;
identifier l;
@@

nm(...) {
<...
- if(...) goto l@p; l:
...>
}
// </smpl>

