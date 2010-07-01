From: "Sandeep Joshi" <sjoshi-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Subject: 4.1 client - LAYOUTCOMMIT
Date: Thu, 1 Jul 2010 16:47:25 -0700
Message-ID: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <bhalevy@panasas.com>
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from p01c12o147.mxlogic.net ([208.65.145.70]:41547 "EHLO
	p01c12o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab0GAXtl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 19:49:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


As per specification value of newoffset4_u.no_offset should be less than or equal to NFS4_MAXFILEOFF.
But, I observe it to be NFS4_MAXFILELEN.


regards,

Sandeep
