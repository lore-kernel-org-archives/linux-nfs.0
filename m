Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36406 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab0FYEoK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jun 2010 00:44:10 -0400
Received: by pwj8 with SMTP id 8so2171066pwj.19
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jun 2010 21:44:09 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Problem: Clients freeze on transfer of large files, w gigabit lan
To: linux-nfs@vger.kernel.org
From: "Jasper Mackenzie" <jasper.mackenzie@gmail.com>
Date: Fri, 25 Jun 2010 16:44:03 +1200
Message-ID: <op.vet93peko2qfwp@foundation>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Good Day All,
    I and many others have been plagued by a problem that can be summarised
as follows:

Client hangs upon copying of large files TO the server. Transfer begins
quickly then hangs, sometimes taking the client o/s with it, until
transfer starts again. In less extreme cases transfer is sporadic.
    I am using nfs4 w gigabit nics.

    My experience is with debian and ubuntu clients and servers, as such I
started a thread on ubuntu forum to find similar cases to give you more to
work from:
http://ubuntuforums.org/showthread.php?p=9269703
    It appears that this problem is not restricted to ubuntu and exists in  
at
least fedora and redhat as well.

More details and user experience is in the above forum thread.

    Help in solving this would be greatly appreciated.

Thanks.

Jasper
