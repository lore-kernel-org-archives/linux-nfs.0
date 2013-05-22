Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:55653 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab3EVJ62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 05:58:28 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 383BE280015
	for <linux-nfs@vger.kernel.org>; Wed, 22 May 2013 11:58:27 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 2B06B13E8A
	for <linux-nfs@vger.kernel.org>; Wed, 22 May 2013 11:58:27 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Tabd8838bb283a9615f2938@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Wed, 22 May 2013 11:58:27 +0200
Received: from zimbratest.desy.de (zimbratest.desy.de [131.169.72.254])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id D8E093E902
	for <linux-nfs@vger.kernel.org>; Wed, 22 May 2013 11:58:26 +0200 (MEST)
Date: Wed, 22 May 2013 11:58:26 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <2007295634.1529248.1369216706282.JavaMail.root@desy.de>
In-Reply-To: <1164976622.1510880.1369209469446.JavaMail.root@desy.de>
Subject: expected unxpected behavior
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi,

we hit some strange behavior which is expected from one side, but unexpected at the same time.
We run our nfs server with v3 and v4. Due to misconfiguration in idmapping, we got some files
to be owned by uid -1. Which is ok, as with v4 server returns nobody. Nevertheless, this
prevent to list the directory with v3. This is the result of uid_valid()/gid_valid() calls
in nfs3xdr.c:decode_fattr3. The uid_valid/gid_valid checks that provided uid/gid are not -1.
Probably this is ok. My confusion is: a) one file with bad uid/gid prevents listing of a
directory, b) in nfs v3 spec uid3 (as well as uid_t in linux) is unsigned int 32 and
value 0xffffffff is absolutely valid.


Tigran.

