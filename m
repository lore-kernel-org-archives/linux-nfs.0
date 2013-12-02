Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f50.google.com ([209.85.212.50]:35196 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448Ab3LBMNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 07:13:51 -0500
Received: by mail-vb0-f50.google.com with SMTP id 10so8305303vbe.23
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 04:13:50 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 2 Dec 2013 13:13:50 +0100
Message-ID: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
Subject: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
From: Joshuah Hurst <joshhurst@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to access NFSv4 Alternate Data Streams (what Solaris,
NexentaOS, Omnios and SmartOS can openat() with the O_XATTR flag) from
a (Suse) Linux client.

OS is Suse Linux 12.3, x86-64, 64bit

Does anyone know how to archive this?

Josh
