Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50378 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab1DTPHe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 11:07:34 -0400
Content-Type: text/plain; charset=US-ASCII
Subject: RE: [pnfs] pnfs read layoutget
Date: Wed, 20 Apr 2011 11:05:05 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4CAC6@daytona.int.panasas.com>
References: <BANLkTi=tOYjnmfsRw+5HXShR4EGd5wsKFw@mail.gmail.com>
From: "Halevy, Benny" <bhalevy@panasas.com>
To: "quanli gui" <gqlxj1987@gmail.com>,
        "linux-pnfs" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This seems like a bug.
If I remember correctly, you are testing the files layout, right?
Does this also happen with the latest kernel v2.6.39-rc3
and / or pnfs-all-2.6.38?

Regards,

Benny

-----Original Message-----
From: quanli gui [mailto:gqlxj1987@gmail.com]
Sent: Wed 2011-04-20 11:47
To: linux-pnfs; Halevy, Benny
Subject: [pnfs] pnfs read layoutget
 
In the code of linux-kernel-2.6.31, we can see that before the read
operation there is the layoutget operation. But in the newly code, for
example, in linux-kernel-2.6.36, before the read operation there only is the
open operation. That meaning that we don't need to get the layout from the
mds? Why remove the layoutget operation before the read operation? How it
reflect on the source code?

