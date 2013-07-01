Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123Ab3GAQEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 12:04:34 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r61G4XQF026662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jul 2013 12:04:33 -0400
Received: from smallhat.bos.devel.redhat.com (vpn-58-250.rdu2.redhat.com [10.10.58.250])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r61G4Wiw022968
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jul 2013 12:04:32 -0400
Message-ID: <51D1A890.1060607@RedHat.com>
Date: Mon, 01 Jul 2013 12:04:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH]: gssd: Fix preferred_realm option handling
References: <20130620195603.GE16125@principal.rfc2324.org>
In-Reply-To: <20130620195603.GE16125@principal.rfc2324.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 20/06/13 15:56, Maximilian Wilhelm wrote:
> 
> Hi,
> 
> the gssd currently ignores any preferred realm given via the -R
> command line option.
> 
> The attached patch fixes that behaviour and makes sure the
> preferrred_realm is used first when searching for a valid principal
> for mount authentication.
> 
> I would be happy if you would apply this. This would close bug #235 in
> bugzilla.
Committed! 

steved.
> 
> Thanks
> Max
> 
