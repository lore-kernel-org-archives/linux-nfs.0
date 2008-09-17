From: Jim Rees <rees@umich.edu>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 09:21:49 -0400
Message-ID: <20080917132148.GA535@citi.umich.edu>
References: <997439.5560.qm@web32601.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.81]:51629 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbYIQNaY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 09:30:24 -0400
In-Reply-To: <997439.5560.qm-VAEUvbQToQWvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are times when you want to increase nfs readahead instead of
decreasing it.  I suggest you make the default 15 but allow tuning it either
up or down.
