Return-Path: linux-nfs-owner@vger.kernel.org
Received: from colin.muc.de ([193.149.48.1]:43255 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab3K0InD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Nov 2013 03:43:03 -0500
Date: Wed, 27 Nov 2013 09:43:00 +0100
From: Albert Fluegel <af@muc.de>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20131127084300.GA37104@colin.muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

sorry, i missed and deleted this posting from Weston Andros Adamson:
http://www.spinics.net/lists/linux-nfs/msg40622.html
so i cannot directly reply anymore. Apologies for messing up the mail
threads a bit.

I reported this issue to Redhat 2012-10-25, please see here:
https://bugzilla.redhat.com/show_bug.cgi?id=869942
and suggested a fix. I'd greatly appreciate, if someone could confirm
to Redhat, that the problem and the approach to fix that is basically the
same, so they'll hopefully backport the patch.

Thank you very much,
 Albert

-- 
Albert Flügel
Lindwurmstraße 51
80337 München
Telefon: +49-89-2010895
Telefon: +49-170-5665444
E-Mail: af@muc.de
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~ jslwkerbiS4kjaZoifUSDfaworu394kjKLw728K2L1NlwkNSD8 ~~~~~~~~~~~~~
