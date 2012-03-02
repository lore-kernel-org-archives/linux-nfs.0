Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62334 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539Ab2CBNc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 08:32:57 -0500
Received: by vbbff1 with SMTP id ff1so1454073vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 05:32:56 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Fri, 2 Mar 2012 14:32:56 +0100
Message-ID: <CAGue13pLLJg+xcSyn-mC9-yPrsvPTEwKz0b_vY+Mm3X_i6VEvw@mail.gmail.com>
Subject: invalid sequence id
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According rfc5661 section 2.10..6.1:


 The first time a slot is used, the requester MUST specify a  sequence
ID of one.

Nevertheless, current client (git://linux-nfs.org/~trondmy/nfs-2.6.git
abd96698613eb27415e7028b6100be930920adc6)

sends starts with zero:


fedora kernel 3.2.7 does it correct.


Regards,
   Tigran.
