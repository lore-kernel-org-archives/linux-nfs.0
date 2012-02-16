Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49782 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab2BPQr6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 11:47:58 -0500
Received: by eekc14 with SMTP id c14so913195eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 08:47:57 -0800 (PST)
Message-ID: <4F3D333A.1000108@tonian.com>
Date: Thu, 16 Feb 2012 18:47:54 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: wireshark decoding of nfsv4.1
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

I stumbled upon a bug in wireshark decoding of NFSv4.1 open res
when delegation_type==OPEN_DELEGATE_NONE_EXT where od_whynone
seems to be ignored.

Who owns that code nowadays?

There seems to be a bug in pynfs in this area as well
which I'm trying to debug.

Benny
