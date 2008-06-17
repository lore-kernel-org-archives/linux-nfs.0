From: Andreas Westin <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org>
Subject: cross-compile nfs-utils
Date: Tue, 17 Jun 2008 14:43:41 +0200
Message-ID: <6043ada4386b12792b4c0d0b64a30c6b@forsaken.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ch-smtp02.sth.basefarm.net ([80.76.149.213]:39091 "EHLO
	ch-smtp02.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756461AbYFQNJd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 09:09:33 -0400
Received: from c83-249-72-185.bredband.comhem.se ([83.249.72.185]:46839 helo=www.forsaken.se)
	by ch-smtp02.sth.basefarm.net with esmtp (Exim 4.68)
	(envelope-from <forsaken-kFn/pJTXB1swFerOooGFRg@public.gmane.org>)
	id 1K8aYQ-0002TW-9D
	for linux-nfs@vger.kernel.org; Tue, 17 Jun 2008 14:44:55 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, 

When you cross-compile nfs-utils 1.1.2 for ARM, locktest and rpcdebug
fails because they don't use the CFLAGS_FOR_BUILD and
CPPFLAGS_FOR_BUILD. This becomes a problem when you use flags which
the host compiler doesn't support such as -mthumb. 

/Andreas

