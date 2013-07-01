Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm47-vm6.bullet.mail.gq1.yahoo.com ([67.195.87.184]:23123 "EHLO
	nm47-vm6.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753087Ab3GAHxY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 03:53:24 -0400
Message-ID: <1372664858.77543.YahooMailNeo@web15903.mail.cnb.yahoo.com>
Date: Mon, 1 Jul 2013 15:47:38 +0800 (CST)
From: drankye <drankye@yahoo.com.cn>
Reply-To: drankye <drankye@yahoo.com.cn>
Subject: What's the status of SPKM3/LIPKEY for NFS4 on Linux
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi all, 
 
About 2 years ago, it was asked “when will we be able to use
LIPKEY on NFS4 on Linux?”. Ref. http://permalink.gmane.org/gmane.linux.nfs/35560.
There Trond replied as below:
“
We're likely to drop the requirement that SPKM3/LIPKEY be a
mandatory
security mechanism for NFSv4 in the revised RFC3530 (a.k.a.
RFC3530bis)
that is being drafted.
 
The reason is that the SPKM3 mechanism (on which LIPKEY
relies) appears
to contain inherent security flaws that are difficult to
fix. The IETF
security group have therefore pretty much killed it as an
option.
Other alternatives to SPKM3 are being discussed, but I'm not
aware of
anything that replaces LIPKEY.
“
I’m wondering today what’s the status of SPKM3/LIPKEY
support for NFS4 on Linux. Does anyone know that? Is SPKM3/LIPKEY dropped from
NFS4 or available now with the inherent security flaws being fixed?
 
Thank you very much for your update. 
 
Regards,
Kai

