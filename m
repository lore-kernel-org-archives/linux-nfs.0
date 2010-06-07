From: Benny Halevy <bhalevy@panasas.com>
Subject: pnfs-submit patches for latest
Date: Mon, 07 Jun 2010 08:42:58 +0300
Message-ID: <4C0C86E2.80105@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "William A. (Andy) Adamson" <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36546 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab0FGFnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 01:43:02 -0400
Received: by bwz11 with SMTP id 11so866839bwz.19
        for <linux-nfs@vger.kernel.org>; Sun, 06 Jun 2010 22:43:01 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not sure what order should we apply your different patchsets so please
help me out.  There are, if I recall correctly:
Alexandros' forgetful client patches
Fred's layoutget patches
Andy's layoutcommit cleanup

I'd appreciate if you guys could rebase your patchsets on the
pnfs-submit branch (in whatever order you think would work) and
then re-send to the list.

Thanks!

Benny
