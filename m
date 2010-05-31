From: Dan Carpenter <error27@gmail.com>
Subject: question about gss_verify_mic_v2()
Date: Mon, 31 May 2010 12:12:34 +0200
Message-ID: <20100531101234.GQ5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:7624 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0EaKMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 May 2010 06:12:46 -0400
Received: by ey-out-2122.google.com with SMTP id d26so192214eyd.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 May 2010 03:12:45 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kevin,

Are we planning to add the sequencing checks later or can I remove the
comment?

net/sunrpc/auth_gss/gss_krb5_unseal.c +202 gss_verify_mic_v2()
	 warn: unused return: seqnum = __be64_to_cpup()

   200          /* do sequencing checks */
   201
   202          seqnum = be64_to_cpup((__be64 *)ptr + 8);
   203
   204          return GSS_S_COMPLETE;
   205  }

regards,
dan carpenter
