Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:38127 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbCESdO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2015 13:33:14 -0500
Received: by pdbfl12 with SMTP id fl12so37143731pdb.5
        for <linux-nfs@vger.kernel.org>; Thu, 05 Mar 2015 10:33:13 -0800 (PST)
Received: from jhereg.jhereg ([50.242.95.105])
        by mx.google.com with ESMTPSA id n5sm7608132pdh.27.2015.03.05.10.33.12
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 10:33:13 -0800 (PST)
Date: Thu, 5 Mar 2015 10:33:02 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: Updates to the NFSv4.2 xdr
Message-ID: <20150305183302.GA74180@jhereg.jhereg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We've just pushed two changes to the XDR:

   struct COPY_NOTIFY4resok {
           nfstime4        cnr_lease_time;
           netloc4         cnr_source_server<>;
   };

became:

   struct COPY_NOTIFY4resok {
           nfstime4        cnr_lease_time;
           stateid4        cnr_stateid;
           netloc4         cnr_source_server<>;
   };

and

   enum netloc_type4 {
           NL4_NAME        = 0,
           NL4_URL         = 1,
           NL4_NETADDR     = 2
   };

became:

   enum netloc_type4 {
           NL4_NAME        = 1,
           NL4_URL         = 2,
           NL4_NETADDR     = 3
   };

Thanks!
