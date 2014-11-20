Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:46935 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756899AbaKTU5V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 15:57:21 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so5506874igi.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Nov 2014 12:57:21 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 20 Nov 2014 15:57:20 -0500
Message-ID: <CAN-5tyE60A+2h6My0Ebb=5j4DbVifDBuG6CjymCRsRefNTMd=w@mail.gmail.com>
Subject: is receiving BAD_STATEID during IO on delegated stateid unrecoverable?
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

As far as I can tell, receiving a BAD_STATEID on an IO operation on a
delegated stateid when there was a local lock acquired for this IO is
unrecoverable — leads to EIO. Codewise, stateid recovery sees that it
has a local lock and marks it lost and retry of the IO operation
returns the EIO.

Is the reason for seizing the IO is that if the server for some reason
revoked this stateid then there is no guarantee about the locks and
thus doing any IO.

This also applies to both 4.0 and 4.1 code as far as I can tell.

Can somebody confirm or tell me if this is wrong?

Thank you.
