Return-Path: <SRS0=egUe=6G=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83741C2BA19
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Apr 2020 02:50:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5EAB720722
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Apr 2020 02:50:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OMborahw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726398AbgDVCua (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Apr 2020 22:50:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50392 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725912AbgDVCua (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2020 22:50:30 -0400
Received: from mail-oi1-x22a.google.com (mail-oi1-x22a.google.com [IPv6:2607:f8b0:4864:20::22a])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 443C4C0610D6
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2020 19:50:30 -0700 (PDT)
Received: by mail-oi1-x22a.google.com with SMTP id k133so621728oih.12
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2020 19:50:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=hf5CAkEGNX7PpP0KMAFbCxGOsEhCF2uAt32uVRcPgo0=;
        b=OMborahwJ0E1KpKW7OKoYCS0KA1S8NcRZzxfNSXsIXkOr+VoAeNUizvfCDxuVS7IxY
         EkmwyctZDj14/NStrPUuapRkc/nKIqZZ/2QjPicMc+tXpiyX5imv7RdgOFAJkASsijpi
         +UfvBROETVr/881DyIgMC4B//j2T0oTJDSfT+EhE0dEhcbJHWEHlo3Jhzuax9YAdxAVr
         5smcjt07WTyCAzIZPQCtkNCAdbarAszQHSQ5WnOVp623nCIkA4Sg+aoNhu8qETsNhUAh
         29iZCerSiftdm2bxymT9DCwzSuhQaXS6fhrZ4nsy/1eSoz+fEvjA15aiIKx4f+/QmsNm
         /BBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=hf5CAkEGNX7PpP0KMAFbCxGOsEhCF2uAt32uVRcPgo0=;
        b=BDBv742lkZI9jMOULUXc1IMBs3mK3BL9nA+Pc/akFNrj6osjD8eNWs2mOPfo9WnNcx
         jvm+wIdtfHAbHuiwtRLqhu1RghRsRiYo6av70sjtUi7Pf2hm9ny5DIQszkPHNXD3FYGS
         mTLH4hsDWGBA0XxuZ/QfbRwefexKRDs7xPTBoyGK0GYn9xBihHnpxxMlaQiZ6+tQH+dg
         F9cAewBbI7ecZo6bLldqmf8VgwIKkcwlweSVWWzBlqDEveCIQ7LMJyf9Ee4kUcNl2DMX
         HXOL12+xkLBrNbvuK5vdqkTY/Q4T4Z1R8y6MrlDicGQpVDC50+dCL1CaaMjUXF6Nzx62
         plOA==
X-Gm-Message-State: AGi0PubmPaEbDtG++a11vBLNeT3LnlRVa+UPUpMtcHA3rTlFo3JEQyYH
        s9W5EKKkWLXbUejkJntDEO3YLvIduyX3v+mK4IUFhwksjcQ=
X-Google-Smtp-Source: APiQypLzO7iqE7s0r+XqeeCHm6aORhWUl8GKFTgLlzytVSPvybwntP6oxkom2Hh0B4ixhffXsLW90j/gTJ/BBpuou0c=
X-Received: by 2002:aca:4542:: with SMTP id s63mr5220910oia.84.1587523829656;
 Tue, 21 Apr 2020 19:50:29 -0700 (PDT)
MIME-Version: 1.0
From:   =?UTF-8?B?5Lq/5LiA?= <teroincn@gmail.com>
Date:   Wed, 22 Apr 2020 10:50:20 +0800
Message-ID: <CANTwqXDJi1LuT1Q382R6qFHm7qMqx6My6aCR0pejNR8BqzFLKg@mail.gmail.com>
Subject: [BUG] fs: nsf: does there exist a memleak in function nfs4_run_open_task?
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi, all:
When reviewing the code of  nfs4_run_open_task, if the rpc_task start
failed, the opendata reference held from kref_get would not be
released even return to upper callers.
I'm wonder that does  there leak the opendata?

static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
{
      ...
      struct rpc_task_setup task_setup_data = {
      ...
.     callback_ops = &nfs4_open_ops,
.     callback_data = data,
      ...
      };
      int status;

      nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
      kref_get(&data->kref);
      ...

     task = rpc_run_task(&task_setup_data);
     if (IS_ERR(task))
            return PTR_ERR(task);
     status = rpc_wait_for_completion_task(task);
    if (status != 0) {
           data->cancelled = true;
           smp_wmb();
     } else
          status = data->rpc_status;
     rpc_put_task(task);

     return status;
}

Best regards,

Lin Yi
