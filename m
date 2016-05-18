Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34454 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbcERVBm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 17:01:42 -0400
Received: by mail-oi0-f48.google.com with SMTP id k142so97738005oib.1
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 14:01:41 -0700 (PDT)
MIME-Version: 1.0
From: Martin Houry <martinhoury@gmail.com>
Date: Wed, 18 May 2016 23:01:21 +0200
Message-ID: <CAEUt8VLF=MaBVrtj_LU1tamzLzkhH0NzTme-DDtOdDmNiUfFnQ@mail.gmail.com>
Subject: Question : Session trunking and tload balancing algorithm
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,
I have a question about session trunking and the algorithm who do load
balancing in.
Is already some ideas to upgrade the algorithm to fit it with the
fluctuation of the bandwith in the network? I have proposed to use the
queue's lenght of the RPC call list to get better speed transfert in a
previous mail. I have tested it and there is a huge performance
difference when the quality of the paths are different.
Do you think it's a good idea to add an option to enable this updrade?
In other word do you think it's useful for the end-user to choose the
algorithm of the session trunking load balancing?

I can send you by mail some graph about my test.

Thank you
Martin
