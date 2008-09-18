From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 20:13:34 -0700
Message-ID: <20080917201334.f680ea1a.akpm@linux-foundation.org>
References: <997439.5560.qm@web32601.mail.mud.yahoo.com>
	<48D1B21E.3060509@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51140 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752661AbYIRDNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 23:13:43 -0400
In-Reply-To: <48D1B21E.3060509-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Sep 2008 11:42:54 +1000 Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> wrote:

> I think having a tunable for client readahead is an excellent idea,
> although not to solve your particular problem.  The SLES10 kernel has a
> patch which does precisely that, perhaps Neil could post it.
> 
> I don't think there's a lot of point having both a module parameter and
> a sysctl.

mount -o remount,readahead=42
