From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 10:59:49 -0500
Message-ID: <497897F5.9030005@RedHat.com>
References: <4970B451.4080201@RedHat.com>	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	<497757D1.7090908@RedHat.com>	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>	<49777988.6010401@RedHat.com>	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>	<4977A385.8000406@melbourne.sgi.com> <20090121225619.GI4295@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48059 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbZAVQCR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2009 11:02:17 -0500
In-Reply-To: <20090121225619.GI4295@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> 
> On the mount case specifically: How far are we from the idea of a mount
> program that can identify most problems itself?  I know its error
> reporting has gotten better....
> 
> I suppose the main feedback mount gets right now is an error code from
> the mount system call, and that may be too narrow an interface to cover
> most problems.  Is there some way we can give mount a real interface it
> can use to find out this stuff instead of just dumping more strings into
> the logs?
Interesting.... Store something like a reason code (similar to what they have
in he Kerberos) in somewhere in the proc file system? 

Its seems to me this is a common problem among network file systems... 

steved.

