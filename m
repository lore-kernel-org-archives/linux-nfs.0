Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42785 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbbCFRAZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2015 12:00:25 -0500
Received: by padfa1 with SMTP id fa1so52819931pad.9
        for <linux-nfs@vger.kernel.org>; Fri, 06 Mar 2015 09:00:25 -0800 (PST)
Received: from jhereg.jhereg ([50.242.95.105])
        by mx.google.com with ESMTPSA id kh5sm9996251pbc.41.2015.03.06.09.00.23
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 09:00:24 -0800 (PST)
Date: Fri, 6 Mar 2015 09:00:23 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Updates to the NFSv4.2 xdr
Message-ID: <20150306170023.GA51311@jhereg.jhereg>
References: <20150305183302.GA74180@jhereg.jhereg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150305183302.GA74180@jhereg.jhereg>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And as a follow-up, I took Jorge's changes for the COPY result:

   struct COPY4res {
           nfsstat4        cr_status;
           write_response4 cr_response;
           bool            cr_consecutive;
           bool            cr_synchronous;
   };

becomes:

truct write_response4 {
           stateid4        wr_callback_id<1>;
           length4         wr_count;
           stable_how4     wr_committed;
           verifier4       wr_writeverf;
   };


   struct copy_requirements4 {
           bool            cr_consecutive;
           bool            cr_synchronous;
   };

   struct COPY4resok {
           write_response4         cr_response;
           copy_requirements4      cr_requirements;
   };

   union COPY4res switch (nfsstat4 cr_status) {
   case NFS4_OK:
           COPY4resok              cr_resok4;
   case NFS4ERR_OFFLOAD_NO_REQS:
           copy_requirements4      cr_requirements;
   default:
           void;
   };

