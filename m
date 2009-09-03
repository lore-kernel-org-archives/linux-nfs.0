Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:34697 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbZICPfd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 11:35:33 -0400
Received: by yxe14 with SMTP id 14so1297173yxe.21
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2009 08:35:35 -0700 (PDT)
In-Reply-To: <20090903135516.GB4566@fieldses.org>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	 <20090902202206.GJ17884@fieldses.org>
	 <524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com>
	 <4A9F6027.9050807@s3group.cz>
	 <524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com>
	 <20090903135516.GB4566@fieldses.org>
Date: Thu, 3 Sep 2009 10:35:35 -0500
Message-ID: <524f69650909030835s41e78436p4b67594cf91de639@mail.gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
From: Steve French <smfrench@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ondrej Valousek <webserv@s3group.cz>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        ffilzlnx@linux.vnet.ibm.com, jra@samba.org, agruen@suse.de
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 3, 2009 at 8:55 AM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Thu, Sep 03, 2009 at 08:54:06AM -0500, Steve French wrote:
>> if someone were able to convince the linux-fsdevel community to change
>> fs/posix_acls.c
>> (or add an fs/cifs_acls.c) to handle NFSv4/CIFS/NTFS ACL evaluation, and add
>> support to store these richer ACLs on disk for the future (e.g. for
>> btrfs), that would be
>> great - but with no local file system in kernel which can store NFSv4 ACLs and
>> no code to evaluate these ACLs in the VFS and with a NACK from fsdevel when
>
> I don't remember that--do you have a pointer?

Aneesh mentioned one strongly worded objection (I remember more resistance
from others too)

http://kerneltrap.org/mailarchive/linux-fsdevel/2006/6/24/313526



-- 
Thanks,

Steve
