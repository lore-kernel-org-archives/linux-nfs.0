From: Sandeep Joshi <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Subject: 4.1 client - LAYOUTCOMMIT & close
Date: Thu, 1 Jul 2010 17:07:55 -0700
Message-ID: <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <bhalevy@panasas.com>
To: "Sandeep Joshi" <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from p01c12o143.mxlogic.net ([208.65.145.66]:37376 "EHLO
	p01c12o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab0GBAMw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 20:12:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In certain cases, I don't see layoutcommit on a file at all even after doing many writes.



Client side operations:

open
write(s)
close


On server side (observed operations):

open
layoutget's 
close


But, I do not see laycommit at all. In terms data written by client it is about 4-5MB.

When does client issue laycommit? 


regards,

Sandeep

