Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:60991 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968169Ab3E3LJe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 07:09:34 -0400
Received: by mail-we0-f174.google.com with SMTP id x50so104585wes.19
        for <linux-nfs@vger.kernel.org>; Thu, 30 May 2013 04:09:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1091403305.30723.1369831764803.JavaMail.root@erie.cs.uoguelph.ca>
References: <BC47EE42-5F58-4555-A49C-4175B75943D8@oracle.com> <1091403305.30723.1369831764803.JavaMail.root@erie.cs.uoguelph.ca>
From: Bram Vandoren <brambi@gmail.com>
Date: Thu, 30 May 2013 13:09:13 +0200
Message-ID: <CACQjR_AFS88vWM12JV0y4+wLupTDTSSVxprNijMyC7zNQ0jErA@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 29, 2013 at 2:49 PM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
>
>>
> Good point. Which leads to the question, "When did the server reboot
> relative to the packet capture?". Was it before the capture started or
> sometime during the 4400 seconds when the client wasn't sending anything or ???

The server rebooted in the beginning of the capture. I think the first
packets indicate the server was up but the nfs daemon was not running
any more. After ~4400 seconds the server was again available.

Thanks,
Bram.
