Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:56214 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbZICNyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 09:54:12 -0400
Received: by ywh26 with SMTP id 26so2686953ywh.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2009 06:54:14 -0700 (PDT)
In-Reply-To: <4A9F6027.9050807@s3group.cz>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	 <20090902202206.GJ17884@fieldses.org>
	 <524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
	 <4A9F6027.9050807@s3group.cz>
Date: Thu, 3 Sep 2009 08:54:06 -0500
Message-ID: <524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
From: Steve French <smfrench@gmail.com>
To: Ondrej Valousek <webserv@s3group.cz>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        ffilzlnx@linux.vnet.ibm.com, jra@samba.org, agruen@suse.de
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 3, 2009 at 1:20 AM, Ondrej Valousek<webserv@s3group.cz> wrote:
>
>> 2) If POSIX->NFSv4 client mapping is done (as had been suggested IIRC
>> by others in the past) at least you lose less data (NFSv4 ACLs are
>> "richer"
>> in function than POSIX ACLs - so at least with the POSIX->NFSv4->POSIX
>> case you are limiting the user to the subset of choices which are actually
>> going to be able to be stored, no inheritence etc.)
>>
> I must say that I do not understand the motivation either. POSIX is not even
> a standard and should be replaced with NFSv4 acls.
> Even now ext3/ext4 support NFSv4 acls (ok. patch is needed but the patch is
> there already).

If someone were able to convince the linux-fsdevel community to change
fs/posix_acls.c
(or add an fs/cifs_acls.c) to handle NFSv4/CIFS/NTFS ACL evaluation, and add
support to store these richer ACLs on disk for the future (e.g. for
btrfs), that would be
great - but with no local file system in kernel which can store NFSv4 ACLs and
no code to evaluate these ACLs in the VFS and with a NACK from fsdevel when
others tried this a few years ago (even after MacOS and others moved to the
CIFS/NTFS ACLs model)

> If the decision was up to me, I would forbid any nfsv4 acls if the server
> can not store them properly (i.e. without any conversion)

That would be a pretty dramatic loss of function - being forced to use
the primitive
mode bits to protect files if the server were Linux - and could be
worseeven NetApp does
some ACL mapping




-- 
Thanks,

Steve
