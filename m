Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45915 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394Ab0EYNZw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 09:25:52 -0400
Received: by gwaa20 with SMTP id a20so1977101gwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 06:25:51 -0700 (PDT)
In-Reply-To: <loom.20100525T092804-609@post.gmane.org>
References: <loom.20100525T092804-609@post.gmane.org>
Date: Tue, 25 May 2010 09:25:50 -0400
Message-ID: <AANLkTilLg16uuaAoR2iXQ0KmGK68L_4Ju-i1k4838qu4@mail.gmail.com>
Subject: Re: Can the pNFS be able to construct high-available about the data ?
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: redshield88888 <redshield88888@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 3:41 AM, redshield88888
<redshield88888@gmail.com> wrote:
> Hi
>
> I wonder that about the pNFS's high availability.
> The pNFS will stripe a file on each DSs, so this file will be currupted when one
> DS has crushed, will not ?


spNFS is an exercise in prototyping,  useful for testing, and good for
demonstrating the power of the protocol to increase bandwidth.  It is
not and has never claimed to be  a production  file system.  There is
no 'fsck'. There is no heart-beat.. There is no stateid recovery, etc.

-->Andy

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
