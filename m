Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48C7DC433F5
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Feb 2022 20:16:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344904AbiBKUQy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Feb 2022 15:16:54 -0500
Received: from mxb-00190b01.gslb.pphosted.com ([23.128.96.19]:55480 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1347932AbiBKUQw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2022 15:16:52 -0500
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id E3F1BCF9
        for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2022 12:16:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1644610610;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=+gMHAHJjUIuVvqgJrQ4D2pppsnOXu6yKlmOVOoarmMg=;
        b=F8dJa5kQyabKC4Xh8onxamNhJjJKH8Xmi5ROENBKPk4H+rgoSuUz+jBB34TT2eqv+rJTyI
        fhVi188igaP80cJuOkoim1V+Dq6mXyJuhr7lE3X7fsf6Mmn1ZKQ2GaOzbt/0kQnx2fNCsZ
        16cit0wFXAoM7hjSORAVjrxatHGaXu8=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-231-9MkCE9ReNCSz43qK2YdHOA-1; Fri, 11 Feb 2022 15:16:48 -0500
X-MC-Unique: 9MkCE9ReNCSz43qK2YdHOA-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id C7E97814246;
        Fri, 11 Feb 2022 20:16:47 +0000 (UTC)
Received: from [10.10.66.2] (ovpn-66-2.rdu2.redhat.com [10.10.66.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 695BA10E54FE;
        Fri, 11 Feb 2022 20:16:47 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Chuck Lever III" <chuck.lever@oracle.com>
Cc:     "Steve Dickson" <SteveD@RedHat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] nfsuuid: a tool to create and persist nfs4 client
 uniquifiers
Date:   Fri, 11 Feb 2022 15:16:43 -0500
Message-ID: <945849B4-BE30-434C-88E9-8E901AAFA638@redhat.com>
In-Reply-To: <C7533D80-25B3-4722-94A9-0440C48B8574@oracle.com>
References: <cover.1644515977.git.bcodding@redhat.com>
 <9c046648bfd9c8260ec7bd37e0a93f7821e0842f.1644515977.git.bcodding@redhat.com>
 <7642FA55-F3F2-4813-86E2-1B65185E6B36@oracle.com>
 <3d2992df-7ef7-50ba-4f11-f4de588620d2@redhat.com>
 <DDB59BD9-8C29-45C3-ABAF-B25EDDB63E09@oracle.com>
 <D0908E76-C163-4DBF-A93C-665492EB9DB2@redhat.com>
 <E2C56D5B-AC77-48D1-9AF6-268406648657@oracle.com>
 <4657F9AE-3B9E-4992-9334-3FF1CF18EF31@redhat.com>
 <C7533D80-25B3-4722-94A9-0440C48B8574@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11 Feb 2022, at 15:00, Chuck Lever III wrote:

>> On Feb 11, 2022, at 2:30 PM, Benjamin Coddington 
>> <bcodding@redhat.com> wrote:
>>
>> All the arguments for exacting tolerances on how it should be named 
>> apply
>> equally well to anything that implies its output will be used for nfs 
>> client
>> ids, or host ids.
>
> I completely disagree with this assessment.

But how, and in what way?  The tool just generates uuids, and spits them
out, or it spits out whatever's in the file you specify, up to 64 chars. 
  If
we can't have uuid in the name, how can we have NFS or machine-id or
host-id?

> I object strongly to the name nfsuuid, and you seem to be inflexible. 
> This
> is not a hill I want to die on, however I reserve the right to say "I 
> told
> you so" when it turns out to be a poor choice.

How does agreeing with you multiple times in my last response and making
further suggestions for names seem inflexible to you?  This is the worst
part of working over email - I think you're misreading my good humor in 
the
face of a drudging discussion as sarcasm or ill will.

Let's find the best name.. I'm still going here.  I do really like
`persistychars`, but I expect that's too fun for everyone.  The name at
least gets closer to your bar of describing exactly what the tool does.

I'm really tired of arguing over the name, and I'm trying my best to 
keep
some good humor about it, and find something that meets everyone's 
needs.

Ben

