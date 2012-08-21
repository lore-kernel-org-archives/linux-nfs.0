Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:60241 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2HUO1S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 10:27:18 -0400
Message-ID: <50339AC2.7000507@parallels.com>
Date: Tue, 21 Aug 2012 18:27:14 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism for
 nfsd
References: <20120710223818.GA6720@fieldses.org> <1341961118.17428.29.camel@lade.trondhjem.org> <20120711170331.GE11432@fieldses.org> <20120711172714.GA13610@fieldses.org> <1342028948.25375.45.camel@lade.trondhjem.org> <20120712221058.GC24162@fieldses.org> <20120713154302.GA32660@fieldses.org> <20120808193659.GA942@fieldses.org> <20120808194359.GB942@fieldses.org> <5022C824.504@parallels.com> <20120821141614.GF9483@fieldses.org>
In-Reply-To: <20120821141614.GF9483@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

21.08.2012 18:16, J. Bruce Fields пишет:
> One other question for Stanislav: I assume module parameters are global,
> and that there's no plan to try to make them per-container?
>

Yep, they will remain global. There may be some options, if you can tune them 
somehow (using sysctl or whatever). But currently I don't think, that module 
parameters should be containerized.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
