Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 733FCC433FE
	for <linux-nfs@archiver.kernel.org>; Tue, 10 May 2022 16:08:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242451AbiEJQL5 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 May 2022 12:11:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48380 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1347284AbiEJQKj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2022 12:10:39 -0400
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4988E6FD11
        for <linux-nfs@vger.kernel.org>; Tue, 10 May 2022 09:06:14 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id C8456608F449;
        Tue, 10 May 2022 18:06:12 +0200 (CEST)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id txM4EpIi-Ise; Tue, 10 May 2022 18:06:12 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id 6431B614E2F4;
        Tue, 10 May 2022 18:06:12 +0200 (CEST)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id v43kaxFEnnMq; Tue, 10 May 2022 18:06:12 +0200 (CEST)
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lithops.sigma-star.at (Postfix) with ESMTP id 312026081104;
        Tue, 10 May 2022 18:06:12 +0200 (CEST)
Date:   Tue, 10 May 2022 18:06:12 +0200 (CEST)
From:   Richard Weinberger <richard@nod.at>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>, david <david@sigma-star.at>,
        bfields <bfields@fieldses.org>,
        luis turcitu <luis.turcitu@appsbroker.com>,
        david young <david.young@appsbroker.com>,
        david oberhollenzer <david.oberhollenzer@sigma-star.at>,
        trond myklebust <trond.myklebust@hammerspace.com>,
        anna schumaker <anna.schumaker@netapp.com>,
        chris chilvers <chris.chilvers@appsbroker.com>
Message-ID: <1306432546.48658.1652198772007.JavaMail.zimbra@nod.at>
In-Reply-To: <200443c8-c53a-a7ff-0876-aff144963267@redhat.com>
References: <20220502085045.13038-1-richard@nod.at> <20220502085045.13038-3-richard@nod.at> <200443c8-c53a-a7ff-0876-aff144963267@redhat.com>
Subject: Re: [PATCH 2/5] exports: Implement new export option reexport=
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [195.201.40.130]
X-Mailer: Zimbra 8.8.12_GA_3807 (ZimbraWebClient - FF97 (Linux)/8.8.12_GA_3809)
Thread-Topic: exports: Implement new export option reexport=
Thread-Index: 5cJROTkkzSsrS3NKvVQhdHqWdlaYIw==
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

----- Ursprüngliche Mail -----
> Von: "Steve Dickson" <steved@redhat.com>
> A compile error...
> reexport.c: In function ‘reexpdb_apply_reexport_settings’:
> reexport.c:335:25: error: label ‘out’ used but not defined
>   335 |                         goto out;
>       |                         ^~~~
> 
> 
>> +		}
>> +	}
>> +
>> +	if (ep->e_fsid) {
>> +		if (ep->e_fsid != fsidnum) {
>> +			xlog(L_ERROR, "%s:%i: Selected 'reexport=' mode requires configured
>> numerical 'fsid=' to agree with reexport db entry",
>> +			     flname, flline);
>> +			ret = -1;
>> +		}
>> +	} else {
>> +		ep->e_fsid = fsidnum;
>> +	}
> I'm assuming this is where the out needs to be
> 
> out:

Patch 3/5 adds the label.
Looks like I messed up something while reordering patches. ;-\

Do you want me to resend the patch series immediately or shall I want for further comments?

Thanks,
//richard
