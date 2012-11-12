Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4398 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab2KLTzM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 14:55:12 -0500
Date: Mon, 12 Nov 2012 14:49:55 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Tomasz Chmielewski <mangoo@wpkg.org>, linux-nfs@vger.kernel.org
Message-ID: <939474821.100.1352749795732.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092D337E@SACEXCMBX04-PRD.hq.netapp.com>
Subject: Re: xattr support in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you restate reasoning why it will never do so, and whether this is the same as saying it will never implement named attributes?

Thanks,

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> No. We will never support xattrs over NFS.
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Tomasz Chmielewski
> > Sent: Monday, November 12, 2012 10:14 AM
> > To: linux-nfs@vger.kernel.org
> > Subject: xattr support in NFS?
> > 
> > Does Linux support xattr in NFS?
> > 
> > IF tries using it in both NFS3 and NFS4 under Debian Lenny (2.6.32,
> both
> > server and client), without success.
> > 
> > # setfattr -n user.comment -v "this is a comment" /mnt/nfs
> > setfattr: /mnt/nfs: Operation not supported
> > 
> > 
> > --
> > Tomasz Chmielewski
> > http://blog.wpkg.org
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the
> > body of a message to majordomo@vger.kernel.org More majordomo info
> at
> > http://vger.kernel.org/majordomo-info.html
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
