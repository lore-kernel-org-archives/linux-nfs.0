From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 06:25:21 -0700 (PDT)
Message-ID: <995475.95604.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32607.mail.mud.yahoo.com ([68.142.207.234]:44689 "HELO
	web32607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752399AbYIQNZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 09:25:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Jim Rees <rees@umich.edu>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-nfs list <linux-nfs@vger.kernel.org>
> Sent: Wednesday, September 17, 2008 3:21:49 PM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> There are times when you want to increase nfs readahead instead of
> decreasing it.  I suggest you make the default 15 but allow tuning it either
> up or down.

 We never needed that in our case. But yes, would be trivial. The question is, whether there should be a maximum, just as a safeguard.

Martin

