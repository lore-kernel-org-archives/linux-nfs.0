Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414AbcD1Un1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Apr 2016 16:43:27 -0400
Subject: Re: [PATCH v5 3/3] gssd: always call gss_krb5_ccache_name
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
References: <1461776287-1427-1-git-send-email-kolga@netapp.com>
 <1461776287-1427-4-git-send-email-kolga@netapp.com>
 <1461849587.15736.12.camel@poochiereds.net>
 <E04BBC00-5923-411B-8025-A662D94D0CDF@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <572275ED.7080200@RedHat.com>
Date: Thu, 28 Apr 2016 16:43:25 -0400
MIME-Version: 1.0
In-Reply-To: <E04BBC00-5923-411B-8025-A662D94D0CDF@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/28/2016 10:11 AM, Kornievskaia, Olga wrote:
>> Also, I think you can probably remove USE_GSS_KRB5_CCACHE_NAME
Good call... Its gone! 

>> > altogether as I don't think it'll be used after this patch.
> I think it is removed… :-/ grep for CCNAME comes up empty.
> 
Its in the aclocal/kerberos5.m4 file... your favorite files! 8-) 

steved.
