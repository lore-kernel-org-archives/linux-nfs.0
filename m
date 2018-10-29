Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE08C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:54:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1E33204FD
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NMR9Z53t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E33204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728205AbeJ3Co3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:44:29 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:33475 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728104AbeJ3Co3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:44:29 -0400
Received: by mail-vs1-f68.google.com with SMTP id 125so5877582vsi.0
        for <linux-nfs@vger.kernel.org>; Mon, 29 Oct 2018 10:54:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=S9ya2wCfDS9i3zRl5eKTTK11c92GVmYU1tcmE43wWto=;
        b=NMR9Z53tE/HYp5FZIznNmj8Ylxg4NDGdFmqz+KmWZ0322lJO9fRaqogAbsjbtvOzO9
         KwXJGUWp3B0MV4H+ybijaol7VYPIwjq2cJwvRyN7N13fIfn359pkE1PrXWf3+HLuHFPp
         aNtO67W0CA3BYzDusX6sVBgtu895Ebb+2t7kM1g0ZfeKfFfy0lBe0G93R3IMkthbbD1X
         kWP3m3QQSElXd+pJojHDPI9vF553+1IstQ/BSBlZbo83StEWmyDcp+NiQn7xXQQ1xQQY
         riEyQA7g3UUooQrU2k4KU6YqpJ++EpXyVa/kz3EOGIIw4MO50u23PMUB/vxKhnSDrdi7
         /rlA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=S9ya2wCfDS9i3zRl5eKTTK11c92GVmYU1tcmE43wWto=;
        b=fV48WAczm00/l5qFkyr8viJ/GKpTYbk3Oh3jRzO6OmOwwE6dHHFNn6bmQNQ16PrJ/L
         YW2LEIG8zGdDKjEzodFosHgQPs3XlbpgWlMSLGK3FmaGv7QFDxtaCj6EixT/G8aeRxeU
         lA/NmKkCOLTim46T6f64E0tzrHsLTcw+Uo2NjpwzR0FI6uq6zLFsfhNcTwMcDG1NyZRw
         o/OSBLlhXPHd/cLogvo7TaODQJX+qSvaVYp4l0VjgUZPI/Rtug4O/vcPGNZ6ZFgyoEYR
         dD67GC1ik88rynkpTyta+LlKDO9vqOt8/yGLuaCWhAR27TN4xfj6o976EiWx1YLaOsP8
         A9zw==
X-Gm-Message-State: AGRZ1gK9uofiuvieqj35MRmPpTpPIWWNNjGBF9JLiIRHP/fcg2dcBxD6
        liusAydxY1JA1s1n83NQ6ao9HfERWLrPZ1RALmWe0Q==
X-Google-Smtp-Source: AJdET5fXYzixSxo0qnU+GEDnRRCxSe/sPSAMQaeO6f51V0cJHkphGM9GOe6yBXpbqnzDkdzZ2sDK02QW1TM1gZAUYec=
X-Received: by 2002:a67:f441:: with SMTP id r1mr6490606vsn.164.1540835689120;
 Mon, 29 Oct 2018 10:54:49 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com> <20181025160739.GC5539@fieldses.org>
In-Reply-To: <20181025160739.GC5539@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 13:54:37 -0400
Message-ID: <CAN-5tyF14PZztzVyYXXxZMSUEg6DiQpb0cnfUxXZk-qE2ChrpA@mail.gmail.com>
Subject: Re: [PATCH v1 00/13] server-side support for "inter" SSC copy
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 12:08 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:52AM -0400, Olga Kornievskaia wrote:
> > This patch series adds support for NFSv4.2 copy offload feature
> > allowing copy between two different NFS servers.
>
> Apologies, it may take me another week or so to get to this....
>
> This is the part that sounds trickiest!:

I'll look for your comments next week. Please note that client side
patches that NFSD depends on have changed (due to the client side
review) so to run/compile the code, please grab all of the latest
client-side patches that I posted.

I'm assuming that async patches are going into 4.20, correct?

>
> > On the destination server, upon receiving a COPY request, the server
> > establishes the necessary clientid/session with the source server.
> > It calls into the NFS client code to establish the necessary
> > open stateid, filehandle, file description (without doing an NFS open).
> > Then the server calls into the copy_file_range() to preform the copy
> > where the source file will issue NFS READs and then do local file
> > system writes (this depends on the VFS ability to do cross device
> > copy_file_range().
>
> --b.
