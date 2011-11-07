Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842Ab1KGQXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Nov 2011 11:23:37 -0500
Message-ID: <4EB80606.90309@RedHat.com>
Date: Mon, 07 Nov 2011 11:23:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: rpcbind -h
References: <20111106155844.GA1790@umich.edu>
In-Reply-To: <20111106155844.GA1790@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/06/2011 10:58 AM, Jim Rees wrote:
> Is there some good reason why the rpcbind '-h' option (bind to given
> address) applies only to the udp listening socket and not to the tcp socket?
No... sounds like a bug to me...

steved.
> 
> And is there any good reason why an nfs3 client not providing any services
> would need to run rpcbind?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
