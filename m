Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932716Ab3LEQhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 11:37:00 -0500
Message-ID: <52A0ABDA.8090903@RedHat.com>
Date: Thu, 05 Dec 2013 11:37:46 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trondmy@gmail.com>, Christoph Hellwig <hch@infradead.org>
CC: Lever Charles Edward <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com> <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com> <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com> <20131205132341.GA3381@infradead.org> <274DEB30-A80C-49C2-9487-BAD980C86F63@gmail.com> <20131205134325.GA25933@infradead.org> <7AB02817-E6DE-486A-A4CB-8A67AF44972A@gmail.com>
In-Reply-To: <7AB02817-E6DE-486A-A4CB-8A67AF44972A@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/12/13 08:45, Trond Myklebust wrote:
> 
> On Dec 5, 2013, at 8:43, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> On Thu, Dec 05, 2013 at 08:41:27AM -0500, Trond Myklebust wrote:
>>>> libgssapi-krb5-2 seems to have dropped the libgssglue dependency in
>>>> unstable, but the others still seem to be be around.
>>>
>>> I thought that Debian installs the Heimdal kerberos libraries by default. Does it have the gssapi hooks?
>>
>> libgssapi-krb5-2 is described as "MIT Kerberos runtime libraries - krb5
>> GSS-API Mechanism" and depends on libkrb5-3 which is "MIT Kerberos
>> runtime libraries".  Nothing Heimdal related in this dependency chain.
> 
> Then it should be able to drop the CITI librpcsecgss and libgssglue.
I would think so.... 

librpcsecgss has already been remove from Fedora and I'll do the
same for libgssglue once f18 is no longer supported...

steved.

> 
> Cheers
>   Trond--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
