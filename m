From: Yudong Gao <stgyd@umich.edu>
Subject: Implementation of delegation
Date: Mon, 12 Jul 2010 14:37:29 -0700
Message-ID: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44166 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab0GLVhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 17:37:50 -0400
Received: by vws5 with SMTP id 5so4884776vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 14:37:49 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am reading the NFS source code of the file open function in kernel
2.6.34, but I cannot find any implementation with delegation to allow
client to open a file locally without contacting the server. We are
tying to use delegation to do something interesting. So I am wondering
how much delegation support specified in the NFS 4.1 protocol is
available in the current Linux implementation?

Thanks a lot!

best,

Yudong
