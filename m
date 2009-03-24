From: Alex Bremer <albremer@googlemail.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 13:08:58 +0100
Message-ID: <7f62dcb30903240508v4b71f8d7mec2e0d8c527a9ad7@mail.gmail.com>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>
	 <20090319193514.GE3072@fieldses.org>
	 <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
	 <49C84EEE.9020405@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:57783 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbZCXMJB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 08:09:01 -0400
Received: by ewy9 with SMTP id 9so2040133ewy.37
        for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2009 05:08:58 -0700 (PDT)
In-Reply-To: <49C84EEE.9020405@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/3/24, Greg Banks <gnb@sgi.com>:
> Alex Bremer wrote:
>> [...]
>>  Would the inheritance work if we
>> used a fully NFS4-ACL compatible filesystem? Is there any for Linux?
>>
>
> There are patches to make ext3 and XFS natively NFSv4 ACL aware.  The
> XFS patches have been shipping in an SGI product for some months now.
>
> http://oss.sgi.com/projects/nfs/nfs4acl/
>

Thanks for that link. I will have a closer look at it.

But if I understood J. Bruce Fields correctly an NFS4-ACL compliant
filesystem wouldn't fix the inheritance problem, too because either
the server has to know the umask or the client has to lookup the
directory ACLs. So there would be no real advantage of using NFS4-ACLs
- most things can be done with PosixACLs.

I really begin to hate these umask settings. From my point of view
these settings should only be used as a last resort fallback.
Filesystem inheritance ACLs should always have precedence.

Alex
