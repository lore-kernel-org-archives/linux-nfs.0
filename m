Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f43.google.com ([209.85.216.43]:33092 "EHLO
	mail-vn0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbDJAXj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 20:23:39 -0400
Received: by vnbf1 with SMTP id f1so1036392vnb.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 17:23:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
Date: Thu, 9 Apr 2015 20:23:38 -0400
Message-ID: <CAHQdGtSbn643SVAZ2Y_VzxmS_b-9=+pqPGWGoHtt25hpHpygLw@mail.gmail.com>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Gregory Boyce <gregory.boyce@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 9, 2015 at 3:34 PM, Gregory Boyce <gregory.boyce@gmail.com> wrote:
> Folks,
>
> I've been encountering a problem with NFS clients attempting to mount
> from a netapp via UDP where the netapp is responding on the wrong
> interface.  On some of our older systems, this mount worked properly,
> while on newer systems nfs-utils ends up failing the mount.  Mounting
> via TCP works fine.
>
> It appears that there has been various related discussions over the
> years, and a relevant Redhat bug opened back in 2006:
>
> http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
> https://bugzilla.redhat.com/show_bug.cgi?id=208244
>
> Is there a general recommendation for people in this sort of
> situation?  I'm assuming the code is currently using connected UDP
> sockets (I'm more of a sysadmin than a developer).  Is there an option
> I'm missing to disable this?  Otherwise does anyone know of a patch to
> change the behavior?
>

This is a server bug.. Those are not fixable on the client.

Trond
