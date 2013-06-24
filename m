Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412Ab3FXRAu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 13:00:50 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5OH0nC6029410
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 24 Jun 2013 13:00:50 -0400
Received: from smallhat.bos.devel.redhat.com (vpn-53-220.rdu2.redhat.com [10.10.53.220])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r5OH0nPt006819
	for <linux-nfs@vger.kernel.org>; Mon, 24 Jun 2013 13:00:49 -0400
Message-ID: <51C87B40.1080203@RedHat.com>
Date: Mon, 24 Jun 2013 13:00:48 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH]: gssd: Fix preferred_realm option handling
References: <20130611093403.GB27345@principal.rfc2324.org> <20130611114114.GB16756@umich.edu> <20130617170247.GA16125@principal.rfc2324.org>
In-Reply-To: <20130617170247.GA16125@principal.rfc2324.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/06/13 13:02, Maximilian Wilhelm wrote:
> Anno domini 2013 Jim Rees scripsit:
> 
>> Maximilian Wilhelm wrote:
> 
>>   +	 * Make sure the preferred_realm (which may have been explicitly set
>>   +	 * on the command line, is tried first. If nothing is found go on with
>>   +	 * the host and local default realm (if that hasn't already been tried).
> 
>> You're missing a close paren there somewhere.
> 
> Indeed. The first '(' should have been a ','.
> 
> Anyone willing to apply this?
Its on my TODO list... and I'll fix the comment up...

steved.

> 
> Thanks
> Max
> 
