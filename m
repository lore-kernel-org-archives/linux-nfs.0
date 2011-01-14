Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61447 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757652Ab1ANPbz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jan 2011 10:31:55 -0500
Received: by iyj18 with SMTP id 18so2599255iyj.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 07:31:54 -0800 (PST)
In-Reply-To: <20110114151945.GA21629@merit.edu>
References: <20110114151945.GA21629@merit.edu>
Date: Fri, 14 Jan 2011 10:31:54 -0500
Message-ID: <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>
Subject: Re: 4.1 no-pnfs mount option?
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

No mount option - just configure your machine to not load any pnfs
layoutdriver modules.

-->Andy

On Fri, Jan 14, 2011 at 10:19 AM, Jim Rees <rees@umich.edu> wrote:
> Is there some way (mount option?) I can ask the client to attempt a 4.1
> (sessions) mount but do not use pnfs?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
