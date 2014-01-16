Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f48.google.com ([209.85.215.48]:51303 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaAPNhD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 08:37:03 -0500
Received: by mail-la0-f48.google.com with SMTP id er20so2512371lab.35
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 05:36:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140115133722.GA12243@umich.edu>
References: <CAACXELkPL0g8SNrYWSGoh+-0Uo4pbHeWGa5rtv_7X6vviAnkMQ@mail.gmail.com>
	<20140115133722.GA12243@umich.edu>
Date: Thu, 16 Jan 2014 05:36:59 -0800
Message-ID: <CAACXEL=J3XeGBtoLAwjSoAQ-sHzDMNtgHrRAeV+wq-+wvEqB5A@mail.gmail.com>
Subject: Re: unable to send TCP SYNs from ports lower than 1024
From: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I didn't think of the switch angle ... inserting an in-line tap on
either side of the switch ... shows that it is dropping these frames.
Thanx for the suggestion

--sk

On Wed, Jan 15, 2014 at 5:37 AM, Jim Rees <rees@umich.edu> wrote:
> Stuart Kendrick wrote:
>
>   Is anyone else seeing this?  This issue prevents NFS client mounting,
>   since the NFS client wants to use source ports below 1024
>
> It seems pretty unlikely this is actually broken without anyone noticing.
> Did you check your iptables and switch acls?
