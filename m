Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab1GYPS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jul 2011 11:18:28 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6PFISTU008170
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jul 2011 11:18:28 -0400
Message-ID: <4E2D8942.9020602@RedHat.com>
Date: Mon, 25 Jul 2011 11:18:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Max Matveev <makc@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Ben England <bengland@redhat.com>
Subject: Re: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
References: <1311270542-2021-1-git-send-email-steved@redhat.com> <20009.12921.103429.724673@regina.usersys.redhat.com>
In-Reply-To: <20009.12921.103429.724673@regina.usersys.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry for the delayed response... I took a day off..  

On 07/22/2011 04:19 AM, Max Matveev wrote:
> On Thu, 21 Jul 2011 13:49:02 -0400, Steve Dickson wrote:
> 
>  steved> Our performance team has noticed that increasing
>  steved> RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
>  steved> increases throughput when using the RDMA transport.
> 
> Did they try new client with old server and vice versa?
> Both read and write?
I believe it was done on the server side, but I've cc-ed the
person who did the testing.... 

steved.
