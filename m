Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33208 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755760Ab1HCXVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 19:21:49 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id C55718A95F
	for <linux-nfs@vger.kernel.org>; Thu,  4 Aug 2011 01:21:48 +0200 (CEST)
Date: Thu, 4 Aug 2011 09:21:41 +1000
From: NeilBrown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Subject: Problems with kerberos auth  - possibly against ADS - since
 nfs-utils-1.2.3
Message-ID: <20110804092141.3461c9ce@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi, 
 I have some reports of problems with kerberos auth in openSUSE 11.4 (using
 1.2.3) which can be fixed by using the openSUSE 11.3 version of rpc.gssd
 (from 1.2.1).

https://bugzilla.novell.com/show_bug.cgi?id=614293

 The important difference seems to be the list of enc_types used in
 limit_krb5_enctypes.

 In 1.2.1 this list is hard coded in the rpc.gssd to 1,3,2 (I think).
 In 1.2.3 this list is taken from the kernel where is it hard coded
  to  18,17,16,23,3,1,2.
 When I patch the 11.4 code to use the old enctype list, it works perfectly.

 So presumably it ends up negotiating one of those other enc_types and
 gets confused by it.

 I'll try to get a comparative tcp dump to see if that helps, but
 if anyone has any idea what the problem might be I'd love to hear
 suggestions.

 The systems are running a 2.6.37 kernel in case that might make a difference.

Thanks,
NeilBrown
