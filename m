From: fche@redhat.com (Frank Ch. Eigler)
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Sat, 17 Jan 2009 11:15:27 -0500
Message-ID: <y0mmydpucww.fsf@ton.toronto.redhat.com>
References: <4970B451.4080201@RedHat.com> <49711BDF.3010605@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson
	<public-SteveD-H+wXaHxf7aLQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFSv4 mailing list
	<public-nfsv4-6DNke4IJHB0gsBAKwltoeQ-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFS Mailing list
	<public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	SystemTAP
	<public-systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
To: Greg Banks
	<public-gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:56143 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761763AbZAQQQB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jan 2009 11:16:01 -0500
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>)
	id 1LODq2-0003fW-BD
	for linux-nfs@vger.kernel.org; Sat, 17 Jan 2009 17:15:58 +0100
In-Reply-To: <49711BDF.3010605-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> (Greg Banks's message of "Sat, 17 Jan 2009 10:44:31 +1100")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:

> I have a patch which changes the definition of the dprintk() macro
> (but *not* dprintk() callsites) to allow enabling and disabling
> individual dprintk() statements through a /proc/ interface.  Would
> you be interested in that?

It would make more sense to me to turn dprintk's into trace_marks, then
use http://lkml.org/lkml/2008/12/30/297 to control transmission of the
data to ftrace.

- FChE

