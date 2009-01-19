From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Mon, 19 Jan 2009 09:27:30 -0500
Message-ID: <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com>
References: <49711BDF.3010605@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36551 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbZASO1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 09:27:35 -0500
In-Reply-To: <49711BDF.3010605-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> (Greg Banks's message of
	"Sat, 17 Jan 2009 10:44:31 +1100")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> writes:

> Steve Dickson wrote:
>> So the ultimate goal would be to replace all the dprintks with trace points
>> but still be able to enable them through the rpcdebug command
> I have a patch which changes the definition of the dprintk() macro (but
> *not* dprintk() callsites) to allow enabling and disabling individual
> dprintk() statements through a /proc/ interface.  Would you be
> interested in that?

That sounds like duplicated work.  How does it differ from Jason Baron's
dynamic printk patches (which I believe are now upstream)?

Cheers,
Jeff
