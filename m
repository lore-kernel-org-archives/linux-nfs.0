Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34995 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab2BPSPV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 13:15:21 -0500
Received: by eaah12 with SMTP id h12so966743eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 10:15:19 -0800 (PST)
Message-ID: <4F3D47B3.1090708@tonian.com>
Date: Thu, 16 Feb 2012 20:15:15 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] 4.1 server tests: add delegation_want tests
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[PATCH 1/5] 4.1 server tests: testReadDeleg recognize also OPEN_DELEGATE_NONE_EXT
[PATCH 2/5] 4.1 server tests: move testReadDeleg from st_open to
[PATCH 3/5] 4.1 server tests: testWriteDeleg
	Note: this test fails against the linux server
[PATCH 4/5] 4.1 server tests: testAnyDeleg
[PATCH 5/5] 4.1 server tests: test NFS4_SHARE_WANT_NO_DELEG
