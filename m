Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:60977 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030754Ab2LGO3k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2012 09:29:40 -0500
MIME-Version: 1.0
In-Reply-To: <20121206195752.GA18585@samba2>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
	<20121206194949.7ab20d56@pyramind.ukuu.org.uk>
	<20121206195752.GA18585@samba2>
Date: Fri, 7 Dec 2012 08:29:39 -0600
Message-ID: <CAH2r5msoPiu7wz-HjnnqTxeBLVEQiMYSnLMaZ+dEr11j6Fo4Ew@mail.gmail.com>
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
From: Steve French <smfrench@gmail.com>
To: Jeremy Allison <jra@samba.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Shilovsky <piastry@etersoft.ru>,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, wine-devel@winehq.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 6, 2012 at 1:57 PM, Jeremy Allison <jra@samba.org> wrote:
> On Thu, Dec 06, 2012 at 07:49:49PM +0000, Alan Cox wrote:
>> On Thu,  6 Dec 2012 22:26:28 +0400
>> Pavel Shilovsky <piastry@etersoft.ru> wrote:
>>
>> > Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).
>>
>> If I have my root fs on NFS then the same applies does it not.
>>
>> Your patches fail to describe the security semantics and what file rights
>> I must have to apply each option. How do I track down a lock user, what
>> tools are provided ? How do the new options interact with the security
>> layer?
>>
>> I don't have a problem with the idea, but it needs a lot more clear
>> description of how it works so the model can be checked and if need be
>> things tweaked (eg needing write to denywrite etc)
>
> And this is where things get really ugly of course :-).
>
> For the CIFSFS client they're expecting to be able to
> just ship them to a Windows server, where they'll
> get the (insane) Windows semantics. These semantics
> are not what would be wanted on a local filesystem.
>
> So unless we just say "these things have Windows
> semantics" (where openers of files can lock out others

I suspect that WINE would have the same need
to ship them to an NFS server as to a Windows server,
and the NFS4 protocol specification also defines these,
although I could not find the same level of detail that MS-FSA
provides (e.g. see section 2.14.10 for the detailed
description of how lock conflicts are checked) but the
semantics are probably the same.

-- 
Thanks,

Steve
