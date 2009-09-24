From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: NFS: nfsroot BUG() hit in latest -git
Date: Thu, 24 Sep 2009 16:11:15 +0200
Message-ID: <f861ec6f0909240711o4c61b8e7r867cd5c7e5f1b1d0@mail.gmail.com>
References: <f861ec6f0909240049q69df95e5wba5260788931667c@mail.gmail.com>
	 <0A59A8E5-E9D6-4A46-BB30-AF779EE5A7D0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:63408 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbZIXOLN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2009 10:11:13 -0400
Received: by bwz6 with SMTP id 6so1328337bwz.37
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2009 07:11:15 -0700 (PDT)
In-Reply-To: <0A59A8E5-E9D6-4A46-BB30-AF779EE5A7D0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 24, 2009 at 3:58 PM, Chuck Lever <chuck.lever@oracle.com> w=
rote:
>> It's hitting the "BUG()" in fs/nfs/client.c::nfs_init_timeout_values=
().
>> it does not show up if I remove the "v3,tcp" from nfsroot
>> parameters, but then the whole userspace boot process takes ages.

> Viro just reported a similar problem. =A0Maybe the attached patch fix=
es it?

Yes it does, thank you.
        Manuel Lauss
