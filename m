Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61926 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab0HYUCQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 16:02:16 -0400
Received: by wyb35 with SMTP id 35so1079346wyb.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 13:02:14 -0700 (PDT)
Date: Wed, 25 Aug 2010 15:02:14 -0500
Message-ID: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
Subject: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
(ubuntu). Do I need to restart the machine?

Or I need to restart nfsd? If so, would you please let me know how to
restart nfsd?

-- 
Regards,
Peng
