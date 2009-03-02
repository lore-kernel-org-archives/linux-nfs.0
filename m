From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [NFS] Using kerberos NFSv4 with Fedora 10
Date: Mon, 2 Mar 2009 10:46:38 -0500
Message-ID: <4d569c330903020746i48ea683ped2a7584fb2e45aa@mail.gmail.com>
References: <49AB946C.5000806@cardiov.ox.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Rodgers <christopher.rodgers-6Ezq7DgQwRAXSZKaUYBEcQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34935 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755030AbZCBRel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 12:34:41 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LeC2I-0001Yj-TF
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2009 04:34:38 +1100
In-Reply-To: <49AB946C.5000806-6Ezq7DgQwRAXSZKaUYBEcQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 2, 2009 at 3:10 AM, Chris Rodgers
<christopher.rodgers-6Ezq7DgQwRAXSZKaUYBEcQ@public.gmane.org> wrote:
> Hi,
>
> I am trying to get two Fedora 10 machines to talk to each other using
> NFSv4 and sec=krb5p, but I do not seem to be having much luck. I would
> appreciate any suggestions for trouble shooting.
>
> Thanks in advance!
>
> Chris

The client machine must be running rpc.gssd.  I don't see any mention
of that anywhere in your message.  (/etc/sysconfig/nfs should have
SECURE_NFS="yes")

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

