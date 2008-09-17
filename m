From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 09:10:49 -0700 (PDT)
Message-ID: <766680.7905.qm@web32608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32608.mail.mud.yahoo.com ([68.142.207.235]:33615 "HELO
	web32608.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752352AbYIQQKu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:10:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding back LKML.


----- Original Message ----
> From: Jim Rees <rees@umich.edu>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-nfs list <linux-nfs@vger.kernel.org>
> Sent: Wednesday, September 17, 2008 5:31:12 PM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> Martin Knoblauch wrote:
> 
>    We never needed that in our case. But yes, would be trivial. The question
>    is, whether there should be a maximum, just as a safeguard.
> 
> Yes.  The default should be (RPC_DEF_SLOT_TABLE - 1), and the maximum should
> be max(xprt_udp_slot_table_entries, xprt_tcp_slot_table_entries) (maybe
> minus one).
> 

The default is NFS_MAX_READAHEAD, which is (RPC_DEF_SLOT_TABLE - 1). Incidentially, your suggested maximum seems to be the same on a default setup (minus one applied).

> I wonder if it would make sense to adjust NFS_MAX_READAHEAD when
> xprt_*_slot_table_entries is changed via sysctl.

I am not sure how useful/practical this is, as currently the ra_factor is applied at mount time.

Cheers
Martin

