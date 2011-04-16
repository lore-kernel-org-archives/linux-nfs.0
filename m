Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57476 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1DPX75 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Apr 2011 19:59:57 -0400
Received: by pzk9 with SMTP id 9so1498747pzk.19
        for <linux-nfs@vger.kernel.org>; Sat, 16 Apr 2011 16:59:56 -0700 (PDT)
In-Reply-To: <BANLkTikAGrM1Djve14PNmkLKO96Hq1t+=A@mail.gmail.com>
References: <BANLkTikAGrM1Djve14PNmkLKO96Hq1t+=A@mail.gmail.com>
Date: Sat, 16 Apr 2011 16:59:56 -0700
Message-ID: <BANLkTi=VzVb31-9eQYOhUWzQJcJaie6OHA@mail.gmail.com>
Subject: Static UID mapping
From: NFS Newbie <nfsnewbie@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I need to deploy NFS in a environment which requires static UID
mappings.  After doing some research online, it seems like NFS used to
support a map_static export option which would let the user specify a
static local/remote UID map in a file.  However, this option seems to
have been removed.

Is this correct, and if so, why was this done?  Are there any alternatives?

Thank you.
