Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 158A8C71153
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Aug 2023 13:53:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230044AbjH2Nwz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Aug 2023 09:52:55 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52984 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233074AbjH2Nw2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Aug 2023 09:52:28 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4D64BB5
        for <linux-nfs@vger.kernel.org>; Tue, 29 Aug 2023 06:51:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1693317108;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=cO0xjhpEIbyDRGh2W69E0QliiyPI0y6q0VdT9HQwIsM=;
        b=Didp7uQ3B2qNDe9nYpSLeTGec7DbzyTNbNaDrn6TNLwpO7/Fji0t2DPmbt0/AWrUW5l4Er
        iQhTSBbsoOfIw7ritQPCuFRNZb2rw2A8gmNo0UvilubbjJaNj5+EHClR+tGba7HHuzoEMW
        RNGxaeXc+gNyDQKlA169mWv425J6pXM=
Received: from mimecast-mx02.redhat.com (66.187.233.73 [66.187.233.73]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-517-0Ylzmtb9PWuDpI77SDLYrQ-1; Tue, 29 Aug 2023 09:35:19 -0400
X-MC-Unique: 0Ylzmtb9PWuDpI77SDLYrQ-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.rdu2.redhat.com [10.11.54.1])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id A31912815E21;
        Tue, 29 Aug 2023 13:35:18 +0000 (UTC)
Received: from [192.168.37.1] (unknown [10.22.48.7])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id A3A2A40C2063;
        Tue, 29 Aug 2023 13:35:17 +0000 (UTC)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Chengen Du <chengen.du@canonical.com>
Cc:     trond.myklebust@hammerspace.com, anna@kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 RESEND] NFS: Add mount option 'fasc'
Date:   Tue, 29 Aug 2023 09:35:16 -0400
Message-ID: <73E82F73-1621-4553-8019-2946EA573415@redhat.com>
In-Reply-To: <CAPza5qe0NBWiKZ1yLyfdPGOsmM=VGqWMs=oWJqVzLRcd8AFyJQ@mail.gmail.com>
References: <20230828055310.21391-1-chengen.du@canonical.com>
 <CAPza5qe0NBWiKZ1yLyfdPGOsmM=VGqWMs=oWJqVzLRcd8AFyJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 28 Aug 2023, at 3:14, Chengen Du wrote:

> Hi,
>
> The performance issue has been brought to our attention by users
> within the Ubuntu community.
> However, it seems to be confined to specific user scenarios.
> Canonical has taken proactive measures to tackle the problem by
> implementing a temporary solution [1], which has effectively resolved
> the issue at hand.
> Nonetheless, our earnest desire is for a definitive resolution of the
> performance concern at its source upstream.
>
> I've taken the initiative to send the patches addressing this matter.
> Regrettably, as of now, I've yet to receive any response.
> This situation leads me to consider the possibility of reservations or
> deliberations surrounding this issue.
> I am genuinely keen to gain insights and perspectives from the
> upstream community.
>
> I kindly ask for your valuable input on this matter.
> Your thoughts would significantly aid my progress and contribute to a
> collective consensus.

Hi Chengen Du,

This patch changes the default behavior for everyone.  Instead of that,
perhaps the new option should change the behavior.  That would reduce the
change surface for all NFS users.

The default behavior has already been hotly debated on this list and so I
think changing the default would need to be accompanied by excellent
reasons.

Ben

