From: Jim Rees <rees@umich.edu>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 11:31:12 -0400
Message-ID: <20080917153112.GA22500@citi.umich.edu>
References: <995475.95604.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.93.161]:53166 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752217AbYIQPkP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 11:40:15 -0400
In-Reply-To: <995475.95604.qm-f6uctMgKLEavuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Knoblauch wrote:

   We never needed that in our case. But yes, would be trivial. The question
   is, whether there should be a maximum, just as a safeguard.

Yes.  The default should be (RPC_DEF_SLOT_TABLE - 1), and the maximum should
be max(xprt_udp_slot_table_entries, xprt_tcp_slot_table_entries) (maybe
minus one).

I wonder if it would make sense to adjust NFS_MAX_READAHEAD when
xprt_*_slot_table_entries is changed via sysctl.
