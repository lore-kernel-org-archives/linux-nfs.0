From: Suchit Kaura <skaura-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Subject: Re: 4.1 client - LAYOUTCOMMIT &amp; close
Date: Fri, 2 Jul 2010 17:08:29 +0000 (UTC)
Message-ID: <loom.20100702T190300-538@post.gmane.org>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com> <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48622 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025Ab0GBRKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Jul 2010 13:10:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1OUjka-0004bO-8h
	for linux-nfs@vger.kernel.org; Fri, 02 Jul 2010 19:10:04 +0200
Received: from host130.bluearc.com ([host130.bluearc.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 19:10:04 +0200
Received: from skaura by host130.bluearc.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 19:10:04 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> We are seriously considering removing the  
> layoutcommit call from the file layout client.
