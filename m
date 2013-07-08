Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f176.google.com ([209.85.215.176]:49552 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3GHNzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 09:55:21 -0400
Received: by mail-ea0-f176.google.com with SMTP id z15so2955930ead.35
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jul 2013 06:55:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
References: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
 <CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
From: "bjschuma@gmail.com" <bjschuma@gmail.com>
Date: Mon, 8 Jul 2013 09:55:00 -0400
Message-ID: <CAMFXNOw7a-uuW8ze+Lz0DeBvLChjgNLmKjPAqiH586NqqirF4g@mail.gmail.com>
Subject: Re: Problem with sharing mounted iso
To: Johan GUILBAUD <guilbaud.johan@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(This should have made it to Johan, but I forgot to enable plain text
mode so vger rejected it)

Hi Johan,

Does the server include "crossmnt" in its /etc/exports options for
/pub?  By default, clients aren't able to cross mountpoints in the
export directory.  Including this option should help!

- Bryan

On Mon, Jul 8, 2013 at 8:47 AM, Johan GUILBAUD <guilbaud.johan@gmail.com> wrote:
> Hello !
>
> I have a problem to access a mounted ISO through NFS protocol
>
> i have a server (RHEL6) on which are mounted ISOs
> i have a lot of client accessing files into ISO via the NFS share
>
> My problem is clients (RHEL5 & 6, Solaris 8 & 10) don't see content of
> ISO folder
>
> In example :
>
> on NFS server i have a folder /pub/ where the ISO are mounted (ie :
> with the iso mybeautifuliso.iso on the mount point
> "/pub/mybeautifuliso/") there are also, for test, text files in /pub/
> NFS shares content of /pub
>
>
> Client see tests text files, and folder "mybeautifuliso" but this one
> is empty...
>
>
> thanks for help
>
> --
> GUILBAUD Johan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
