Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:53610 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030254Ab3DSNdE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Apr 2013 09:33:04 -0400
Received: by mail-ie0-f172.google.com with SMTP id c12so677570ieb.17
        for <linux-nfs@vger.kernel.org>; Fri, 19 Apr 2013 06:33:04 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 19 Apr 2013 23:33:04 +1000
Message-ID: <CADmarkWfv5+U1722Gj8U2xVSa5On34t+bcf_R2gXQ=BjmWiMPg@mail.gmail.com>
Subject: NFSv4 - Does it suffer from clashes when using crossmnt/nohide?
From: "linuxinsidev2 ." <linuxinsidev2@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

>From what I can tell, if I use NFSv3 with nohide for sharing multiple
disks under one export, it can result in inode clashes.

Does NFSv4 suffer from this too?
