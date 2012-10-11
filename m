Return-Path: linux-nfs-owner@vger.kernel.org
Received: from medousa.rus.uni-stuttgart.de ([129.69.1.57]:52403 "EHLO
	medousa.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932170Ab2JKOUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 10:20:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by medousa.rus.uni-stuttgart.de (Postfix) with ESMTP id D5B2337F45
	for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 16:20:36 +0200 (CEST)
Received: from medousa.rus.uni-stuttgart.de ([127.0.0.1])
	by localhost (medousa.rus.uni-stuttgart.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Cq_aPCX2LoyB for <linux-nfs@vger.kernel.org>;
	Thu, 11 Oct 2012 16:20:35 +0200 (CEST)
Received: from tindra.iws.uni-stuttgart.de (tindra.iws.uni-stuttgart.de [129.69.98.190])
	by medousa.rus.uni-stuttgart.de (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 16:20:35 +0200 (CEST)
Date: Thu, 11 Oct 2012 16:20:35 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121011142034.GA4304@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some more news about my problem. Thanks to all, who read this thread and
made their thoughts about it.

* I found not any significant kernel messages regarding stale
  handles in syslog or dmesg.

* The question about "noac"-mount-parameter brought me to check more mount
  options. The parameter lookupcache is quite signifcant. If I set it 
  to "none", the problem disappears. while with the values "positive" or "all"
  the problem persits.

  - Though if I mount first with "none" and later with "all"
    the problem disappeared but only until reboot when it then was 
    mounted with "all".
  - I checked this under openSUSE-12.2.
  - I made a quick check with openSUSE 11.4 whether "none" takes there
    also away the problem.

Best regards, David
