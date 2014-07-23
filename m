Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:39771 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbaGWQ4P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 12:56:15 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so1215069iec.40
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 09:56:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140723185419.7a947ada@harpe.intellique.com>
References: <CAB7xdikp2ab=oqQKz+DVLh0D5G9aB7EMd4XWttLh3qFE8Fp9qA@mail.gmail.com>
	<20140723185419.7a947ada@harpe.intellique.com>
Date: Wed, 23 Jul 2014 09:56:14 -0700
Message-ID: <CAB7xdiku-fviN-oNUJt=Rstr5rWL3ac+anHUEipeyMKySMv4jg@mail.gmail.com>
Subject: Re: how to setup pNFS
From: sheng qiu <herbert1984106@gmail.com>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Emmanuel,

thanks for reply.

yes, i compiled the pNFS kernel and boot from that kernel.

Thanks!

On Wed, Jul 23, 2014 at 9:54 AM, Emmanuel Florac <eflorac@intellique.com> wrote:
> Le Wed, 23 Jul 2014 09:13:51 -0700
> sheng qiu <herbert1984106@gmail.com> écrivait:
>
>> i am trying to set up pNFS server and client. is there any document
>> can help that?
>> i tried to follow the
>> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions, but
>> i did not have /proc/fs/nfsd/pdfs_dlm_device entry.
>
> Did you compile the pNFS kernel? Then did you reboot using that kernel?
> This is step 0 in the instructions.
>
> --
> ------------------------------------------------------------------------
> Emmanuel Florac     |   Direction technique
>                     |   Intellique
>                     |   <eflorac@intellique.com>
>                     |   +33 1 78 94 84 02
> ------------------------------------------------------------------------
