From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: sharing some files (and not folders) over NFS
Date: Mon, 2 May 2011 07:46:18 -0700 (PDT)
Message-ID: <395629.71734.qm@web111701.mail.gq1.yahoo.com>
References: <416818.76742.qm@web111712.mail.gq1.yahoo.com> <1304347223.7830.8.camel@lade.trondhjem.org>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm3.bullet.mail.sp2.yahoo.com ([98.139.91.73]:25432 "HELO
	nm3.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759726Ab1EBOqT convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 10:46:19 -0400
In-Reply-To: <1304347223.7830.8.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>Diskless/NFSroot systems do this all the time
Well I have setup diskless nfs but have no idea about that. Can you exp=
lain more or give a link on that?
=A0

// Naderan *Mahmood;


----- Original Message -----
=46rom: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Sent: Monday, May 2, 2011 7:10 PM
Subject: Re: sharing some files (and not folders) over NFS

On Mon, 2011-05-02 at 07:34 -0700, Mahmood Naderan wrote:
> Hi,
> Is it possible to share passwd, group and shadow files over nfs?
> Since a shared folder needs to be defined in /etc/fstab (on the desti=
nation), I wonder how can I do that for files?

Diskless/NFSroot systems do this all the time.

Cheers
=A0 Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
