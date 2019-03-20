Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14B9EC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 14:09:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C443C2070D
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 14:09:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="pR2pXrkt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726595AbfCTOJA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 10:09:00 -0400
Received: from mail-vs1-f41.google.com ([209.85.217.41]:36611 "EHLO
        mail-vs1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726067AbfCTOJA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 10:09:00 -0400
Received: by mail-vs1-f41.google.com with SMTP id n4so1562136vsm.3
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 07:08:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MzD/mXnE0GQXKG3l4IO09duDzjKGkOX12Xq8YvLr8pg=;
        b=pR2pXrktpovJL/b2hWmMdiZWq7CW5g1ErQGfFbmegOIYKWh2o70rwbXwBtU1vnfhlv
         20q6RHo1QWIeU3Cb9FtJaCmz+/bOU6HQiev7G3Z2FWUi/HBZCiB1Iy3rs0KF3mQl8mMb
         ROUiZb30agVfh/X8zWDLWMPBEqEvxSbebBJSS+/Zf+VosbEK45zY8nQoLzUZjbZhkCQt
         RYCU4rVMMYEs9UMZ8CMLQEKG5JBn1EJt3/ZD9+/hE8Y0WANverdJlwcakJWMheNhHui8
         Eo0mWGEEkqAhE560fsNz0Wl4C5xnMzts7ZkpEI40/hbZ0u5MBr/LjZEfBXtOuNXCdUYF
         ZcsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=MzD/mXnE0GQXKG3l4IO09duDzjKGkOX12Xq8YvLr8pg=;
        b=DgzGQKOuAUGBPldvV+R43zn6ZcHgknIVpWK92zbgu6L1tp7ofRJEfqRjQf+RwZsjKH
         Rqz1GGgXYtvrB6EH8V2L1t1mMZGZeF800ro+U2Q5WJ5sh0RKl5iog/E/rJze2DbhtQmJ
         i4kRXpBYwZAdS1IZZ1DJ7sqPE7B30AVAkALsqzxjF3k7bckoHbkd4a/AXC12fdRgyXp+
         Hxy6P1hP1UOAQuUYQLVtHcjTw0t6EcPexCJ6ket0YGWB41ZZ3uSCxF9fx9fV3WpHvrMo
         d5aRNwnB3ChOaoIhq7bw9wdTATLee6aOxrrisYiXSDRYo4SnK3nDgOBxPpeg8QscAUVy
         mNmw==
X-Gm-Message-State: APjAAAU702VVJJ2Q8uMogzGabs2O3OF3aQcQ5HoE/gQNYqiYptid1gK8
        C0askBg9roa0d24v7RkZpunaVhCMidaLxnBitDYwx/0q
X-Google-Smtp-Source: APXvYqzvepyClKWxV6lxF87qw9sBZIg/s1pm/SOKMMeyDJuIi+G4OEOkqfWB87t1AGE5wa6MCJEfhKP9hdom3o3sQeA=
X-Received: by 2002:a67:8210:: with SMTP id e16mr4801359vsd.85.1553090939014;
 Wed, 20 Mar 2019 07:08:59 -0700 (PDT)
MIME-Version: 1.0
References: <CANpxKHExiJUMFBySUU0kixEV3d00Mo5Ze-matCans5JcOF5BhQ@mail.gmail.com>
In-Reply-To: <CANpxKHExiJUMFBySUU0kixEV3d00Mo5Ze-matCans5JcOF5BhQ@mail.gmail.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Wed, 20 Mar 2019 10:08:47 -0400
Message-ID: <CAN-5tyFBcBqS6mHTpf=oTbvf4BWRFk9J_On_8YVXTDPnHCJ2rQ@mail.gmail.com>
Subject: Re: Cannot check if nfsv4 is running or not by rpcinfo
To:     Naruto Nguyen <narutonguyen2018@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a specific question related to that deployment.

rpcinfo -T tcp 172.17.5.13 100003 4 works for a typical linux client/server.

I suggest you contact Redhat to answer this specific question.

On Tue, Mar 19, 2019 at 11:53 AM Naruto Nguyen
<narutonguyen2018@gmail.com> wrote:
>
> Hi everyone,
>
> As the information from this link
> https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html-single/storage_guide/#mount-shares-instance,
> I see that we have to query if Manila nfsv4 is running or not by:
>
> rpcinfo -T tcp -a 172.17.5.13.8.1 100003 4
>
> I cannot use
>
> rpcinfo -T tcp 172.17.5.13 100003 4
>
> It will be stuck and other command like " rpcinfo -T tcp -n 2049
> 172.17.5.13 nfs 4 leads to "rpcinfo: RPC: Port mapper failure - Timed
> out" but these commands are  successful with nfsv3 and even on some
> other nfsv4, not Manila nfsv4.
>
> Could you please let me know why I cannot use other commands, but have
> to specify "8.1" (2049) in server address? Does it depend on nfs4
> server implementation or if we have any specification standard to
> query nfsv4 running?
>
> Thanks a lot
> Best regards,
> Naruto
