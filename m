Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758562Ab2JYObA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 10:31:00 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9PEUoXO019737
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 10:30:55 -0400
Message-ID: <50894D14.9090101@RedHat.com>
Date: Thu, 25 Oct 2012 10:30:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 05/10] nfsdcltrack: add a new "one-shot" program for
 manipulating the client tracking db
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com> <1351092359-25842-6-git-send-email-jlayton@redhat.com> <5089371A.9010005@RedHat.com> <20121025095327.1d463b4c@corrin.poochiereds.net>
In-Reply-To: <20121025095327.1d463b4c@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/10/12 09:53, Jeff Layton wrote:
>> Is needs_arg really necessary? Once the function is found, just pass 
>> > it the rest of argv and let the function decide if there should
>> > be an argument or not... but again.. just a nit... 
>> > 
>> > steved. 
> No, it's not strictly necessary. The alternative though is to make the
> command functions do argv processing, which seemed more ugly to me. I
> tend to prefer to keep argv processing in a single place since it can
> get sort of hairy to work through the bounds checks after getopt and
> such.
> 
> If you feel strongly about it, I can try to change it, but I don't
> think the result will be cleaner.
> 
Like I said its a nit... Just a different way to look at it... no
issues here keeping it as is... 

steved.
