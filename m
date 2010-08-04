Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35545 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336Ab0HDEbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 00:31:47 -0400
Received: by iwn7 with SMTP id 7so5791333iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 03 Aug 2010 21:31:46 -0700 (PDT)
Date: Wed, 4 Aug 2010 14:31:46 +1000
Message-ID: <AANLkTik_awWoER22GmhYeJw2cN4GoJe1Gj7SCVetMzte@mail.gmail.com>
Subject: shutting down socket
From: hce <webmail.hce@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am running a networking application on CentOS 5, it got a SIGTERM
and the application terminated. I looked at dmesg file and found
following an error:

rpc-srv/tcp: nfsd: got error -32 when sending 36 bytes - shutting down socket

Could that error result a SIGTERM? If yes, what could possibly cause
the nfsd error to shut down the socket?

Thank you.

hce
