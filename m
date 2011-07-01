Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:48578 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755080Ab1GAHAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 03:00:01 -0400
Received: from odpn1.odpn.net [212.40.96.53]
	by odpn1.odpn.net for linux-nfs@vger.kernel.org
	id 1QcXLT-00027k-AB; Fri, 01 Jul 2011 08:36:55 +0200
From: "Gabor Z. Papp" <gzp@papp.hu>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils 1.2.4
Date: Fri, 01 Jul 2011 08:36:55 +0200
Message-ID: <x6tyb65wxk@gzp>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

lo lo,

trying to configure nfs-utils 1.2.4 with the options below:

--disable-gss --disable-kprefix --enable-mount --enable-nfsv3
--disable-nfsv4 --with-statduser=nobody --with-statedir=/var/lib/nfs"
--without-tcp-wrappers --disable-tirpc

but getting the following error:

[...]
checking size of socklen_t... 4
configure: error: conditional "CONFIG_NFSIDMAP" was never defined.
Usually this means the macro was only invoked conditionally.
