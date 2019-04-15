Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12103C282DA
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 17:01:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D49CD218D0
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 17:01:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UxO1pjNe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727858AbfDORBM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Apr 2019 13:01:12 -0400
Received: from mail-oi1-f178.google.com ([209.85.167.178]:44179 "EHLO
        mail-oi1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727301AbfDORBL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Apr 2019 13:01:11 -0400
Received: by mail-oi1-f178.google.com with SMTP id i21so14387719oib.11
        for <linux-nfs@vger.kernel.org>; Mon, 15 Apr 2019 10:01:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=9AJl5W8uF1SskrHjKuyXVSXxrqEHESGcl/9Zba/vRVM=;
        b=UxO1pjNejWBo7iGNQFMSzrUQ+l3pqLHPRu1h361gUtolclxVCoBS8JVKwXXp7WFTVe
         y/aeAlDybDiORSyYDgN8XFL+X8EIlk4JMVt2Uz5Y8MQdCYyl6PAQFirducgSmqVHmEpg
         Lb1/NPxPast6T2ug7UjEkQGV1rG00nz2mJ1UDvgHgm+WUCCIFgteQpyvDi7as2LZ8r/x
         l4ci7A9Kaw3dQQWWcOHD1oCVD5R/kUuulOXQR0PgZPxZmaI5jJDYNDfrY9ezSHTPAZKG
         MyjA5uvoqgdBs98DQBzeTWLOKZcLMmHlGykGG0V0eHq8hrGxlOjSRQ0xI8HCaTWm1n/d
         exjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=9AJl5W8uF1SskrHjKuyXVSXxrqEHESGcl/9Zba/vRVM=;
        b=f0pFJriJKkGxQQYzmYroc5X32dT3VGPeH/TbOPCnnTJfNls0XArOhc1YjqvzJaDgYX
         XgW/uUFTc8Ak5/xnjt98fXbpOGG2mCfch3qBdqgXCNzNjbzXEu3/7N/+73NtaDHrxGks
         Dw7CqzFzOzdvSy/VGCcCLkUMLKhhmxrLTf+Ojsu04w2aKc0rxyeGN8CHT1k5CmQKLxFu
         CTsBaYp+qlxIdHtCEMtOP2Fx1KXChCMyEpbH0XZaspCNsZuGZLhpakOeVJX7JsVBj8k8
         T4pj4JE5EX1TYjgqy8irocgk6poDXolp4qGFgfiZb1Exzxp1nf9HU8xJSUgwq/S0sg+0
         LVZQ==
X-Gm-Message-State: APjAAAXbhQ9u7H5lzDwDrHforbrxcVb9s3Jgv4QSn38YTxPa/LjmZixU
        5xumY+6JBUcXO2d04j18/LnH5jwCw9vU8wisL19+oQ==
X-Google-Smtp-Source: APXvYqwL2vdG9G8lqpUfcuKHyEXPeXNa82DXa5GI3TbPkya3yEMEFkmsGXvfohz+xHxoQ0G12JMDDGI6cFcp+tesJB8=
X-Received: by 2002:aca:f3c6:: with SMTP id r189mr19644794oih.53.1555347667578;
 Mon, 15 Apr 2019 10:01:07 -0700 (PDT)
MIME-Version: 1.0
References: <CANUurQovk32SFS_jDMpgmM-CktFJGF1yd5Fv_JOW2BFe4DsJPg@mail.gmail.com>
In-Reply-To: <CANUurQovk32SFS_jDMpgmM-CktFJGF1yd5Fv_JOW2BFe4DsJPg@mail.gmail.com>
From:   Bruno Santos <bacmsantos@gmail.com>
Date:   Mon, 15 Apr 2019 18:00:56 +0100
Message-ID: <CANUurQr77yK5q6cKc3oFEeLE0ZdyEDDHmyiWCAWsWqVjfGGgjw@mail.gmail.com>
Subject: Fwd: nfs v4.2 leaking file descriptors
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi all,

We have a debian stretch HPC cluster(#1 SMP Debian 4.9.130-2
(2018-10-27)). One of the machines mounts a couple of drives from a
Dell compellent system and shares it across a 10GB network to 4
different machines.

We had the nfs server crashing a few weeks ago because the file-max
limit had been reached. At the time we increased the number of file
handles it can handle and been monitoring since. We have noticed that
the number of entries on that machine keeps increasing though and
despite our best efforts we have been unable identify the cause.
Anything I can find related to this is from a well known bug in 2011
and nothing afterwards. We are assuming this is caused but a leak of
file handles on the nfs side but not sure.

Does anyone has anyway of figuring out what is causing this? Output
from the file-ne, lsof, etc is below.

Thank you very much for any help you can provide.

Best regards,
Bruno Santos

:~# while :;do echo "$(date): $(cat /proc/sys/fs/file-nr)";sleep
30;done
Mon 15 Apr 17:23:11 BST 2019: 2466176   0       4927726
Mon 15 Apr 17:23:41 BST 2019: 2466176   0       4927726
Mon 15 Apr 17:24:11 BST 2019: 2466336   0       4927726
Mon 15 Apr 17:24:41 BST 2019: 2466240   0       4927726
Mon 15 Apr 17:25:11 BST 2019: 2466560   0       4927726
Mon 15 Apr 17:25:41 BST 2019: 2466336   0       4927726
Mon 15 Apr 17:26:11 BST 2019: 2466400   0       4927726
Mon 15 Apr 17:26:41 BST 2019: 2466432   0       4927726
Mon 15 Apr 17:27:11 BST 2019: 2466688   0       4927726
Mon 15 Apr 17:27:41 BST 2019: 2466624   0       4927726
Mon 15 Apr 17:28:11 BST 2019: 2466784   0       4927726
Mon 15 Apr 17:28:41 BST 2019: 2466688   0       4927726
Mon 15 Apr 17:29:11 BST 2019: 2466816   0       4927726
Mon 15 Apr 17:29:42 BST 2019: 2466752   0       4927726
Mon 15 Apr 17:30:12 BST 2019: 2467072   0       4927726
Mon 15 Apr 17:30:42 BST 2019: 2466880   0       4927726

~# lsof|wc -l
3428
