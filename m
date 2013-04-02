Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761319Ab3DBTKn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:10:43 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32JAh5U020008
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 15:10:43 -0400
Message-ID: <515B2D36.5080900@RedHat.com>
Date: Tue, 02 Apr 2013 15:10:46 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>,
        =?UTF-8?B?R8O8bnRoZXIgRGVzY2hu?= =?UTF-8?B?ZXI=?=
	<gdeschne@redhat.com>
Subject: Re: Allow building nfs-utils directly against GSSAPI
References: <1364317202.2660.132.camel@willson.li.ssimo.org>
In-Reply-To: <1364317202.2660.132.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 26/03/13 13:00, Simo Sorce wrote:
> Libgssglue is not really useful anymore, it is a sort of middleman that
> wraps the actual GSSAPI that is already pluggable/extensible via shared
> modules.
> 
> In particular libgssglue interferes with the workings of gss-proxy in my
> case.
> 
> The attached patch makes building against libgssglue optional and
> defaults to not build against libgssglue and instead builds directly
> against the native GSSAPI.
> 
> ./configure --enable-gss
> will now build against GSSAPI
> 
> ./configure --enable-gss --with-gssglue
> will keep building against libgssglue in case someone still needs it for
> whatever reason.
Committed...

steved.
