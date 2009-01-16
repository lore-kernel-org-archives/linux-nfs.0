From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Sat, 17 Jan 2009 10:44:31 +1100
Message-ID: <49711BDF.3010605@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:60854 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755060AbZAPXou (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 18:44:50 -0500
In-Reply-To: <4970B451.4080201-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> So the ultimate goal would be to replace all the dprintks with trace points
> but still be able to enable them through the rpcdebug command
I have a patch which changes the definition of the dprintk() macro (but
*not* dprintk() callsites) to allow enabling and disabling individual
dprintk() statements through a /proc/ interface.  Would you be
interested in that?

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

