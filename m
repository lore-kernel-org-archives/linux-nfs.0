From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: AES support for RPCSEC_GSS?
Date: Tue, 12 Feb 2008 02:20:07 +0100
Message-ID: <20080212012007.GA6993@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:4004 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932AbYBLCJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 21:09:51 -0500
Received: from clipper.ens.fr (clipper-gw.ens.fr [129.199.1.22])
          by nef2.ens.fr (8.13.6/1.01.28121999) with ESMTP id m1C1K9tJ026955
          for <linux-nfs@vger.kernel.org>; Tue, 12 Feb 2008 02:20:09 +0100 (CET)
Received: from goelette.ens.fr (root@goelette [129.199.129.6]) by clipper.ens.fr (8.13.1/jb-1.1)
	id m1C1K7hp004488 for <linux-nfs@vger.kernel.org>; Tue, 12 Feb 2008 02:20:07 +0100 (MET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

in all the faqs it is said that there is no working support for
anything else than DES which is a bit outdated and not secure
nowadays.

It seemed to me that there was some code in the nfs-utils which
would do some security negociation (somewhere around utils/gssd/krb5_util.c),
but the kernel had nothing to support that.

I suppose this will be the last thing to be done once the security features
are working with the three versions of NFS.

What are the missing features in this field, and would it be difficult to
add support for other encryption schemes?

Regards,
Quentin Godfroy
