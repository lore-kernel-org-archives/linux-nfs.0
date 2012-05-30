Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39946 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab2E3PmL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2012 11:42:11 -0400
Received: by wibhn6 with SMTP id hn6so4007957wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2012 08:42:09 -0700 (PDT)
Message-ID: <4FC63FCB.7020007@tonian.com>
Date: Wed, 30 May 2012 18:42:03 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: nfsv4 list <nfsv4@ietf.org>
CC: NFS list <linux-nfs@vger.kernel.org>, Lev Solomonov <solo@tonian.com>
Subject: What should the server do for LAYOUTRETURN with lrf_length==0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since no bytes are covered in this case the spec. appears to indicate that the
server will just be silent about that and do nothing.  However a 0 length return
doesn't make much sense so would we like the server to return NFS4ERR_INVAL instead?

Benny
