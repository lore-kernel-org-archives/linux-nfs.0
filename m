Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759700Ab1LOXe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 18:34:57 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFNYvVe025815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 18:34:57 -0500
Message-ID: <4EEA841F.7090803@RedHat.com>
Date: Thu, 15 Dec 2011 18:34:55 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] clstated: add a daemon to track NFSv4 client names
 on stable storage (RFC)
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>	<4EE8BF63.6080906@RedHat.com>	<20111214103247.3a67515f@tlielax.poochiereds.net>	<4EE8C45B.30207@RedHat.com>	<20111214110538.2adaf048@tlielax.poochiereds.net>	<4EE8CE18.2040306@RedHat.com>	<20111214113432.786ffbf7@tlielax.poochiereds.net>	<4EE9079D.2000607@RedHat.com>	<20111214160654.7c36fdc0@tlielax.poochiereds.net>	<4EE922EA.1010408@RedHat.com> <20111214204658.56063a5e@corrin.poochiereds.net>
In-Reply-To: <20111214204658.56063a5e@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/14/2011 08:46 PM, Jeff Layton wrote:
> Not to put too fine a point on it, but so far most of what I'm hearing
> is fear, uncertainty and doubt about using sqlite for this. Does anyone
> have a real technical reason as to why it's not suitable for this
> purpose?
> 
Nope... Go for it!

steved.
