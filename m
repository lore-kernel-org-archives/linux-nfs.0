From: "Dilip Kumar" <udilipkumar@gmail.com>
Subject: Bug in NFSV3 ACCESS Procedure reply
Date: Wed, 27 Aug 2008 12:41:34 -0700
Message-ID: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:3232 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbYH0Tlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 15:41:36 -0400
Received: by fg-out-1718.google.com with SMTP id 19so51619fgg.17
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2008 12:41:35 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I noticed a bug in the access rights of a NFSV3 ACCESS Reply. If a
directory was created with only write permissions for the owner (chmod
200 directory), we expect the modify, extend and delete bits (access =
0x1C) to be set for this directory in the reply to an ACCESS RPC call
with access = 0x1F send by the owner. Instead the NFS server on Linux
returns an ACCESS Reply with access set to 0x0 (none of the bits were
set). I tried checking this against Solaris server and it returns the
expected access rights 0x1C. The Linux server I was using for testing
was 2.6.9-1.667smp and the Solaris server was SunOS 5.8
Generic_108528-22 Ultra Sparc-IIi.

Please let me know if you need further details regarding this issue.

Thanks
Dilip Kumar
