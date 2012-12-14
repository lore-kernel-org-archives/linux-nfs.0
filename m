Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:41362 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143Ab2LNTTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2012 14:19:19 -0500
MIME-Version: 1.0
In-Reply-To: <20121214153000.62af6cbc@pyramind.ukuu.org.uk>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
	<20121207161602.GA17710@infradead.org>
	<495d17310e0a687d446afc86def0f058@office.etersoft.ru>
	<20121212083401.GW5010@snowdrop.l8s.co.uk>
	<CAKywueSN++ZCNJ1zbET_axuwXd2ZujvSof9H82E3AdeZWY_BgQ@mail.gmail.com>
	<20121214153000.62af6cbc@pyramind.ukuu.org.uk>
Date: Fri, 14 Dec 2012 13:19:18 -0600
Message-ID: <CAH2r5muRyB2529EcQXFysrSDpMKe0m3JfiEc5929O6oTmG-ThQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
From: Steve French <smfrench@gmail.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Pavel Shilovsky <piastry@etersoft.ru>, David Laight <david@l8s.co.uk>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 14, 2012 at 9:30 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> We can make this feature (passing O_DENY* flags received from clients
>> to filesystem) can be turned on/off on Samba/NFS server to let this
>> particular use case work. In general, I think we really need to be
>> sure that nobody has a read access for files that a Windows process
>> opened with O_DENYREAD (because there can be important reasons for the
>> Windows process to do so).
>
> It should only affect windows emulated tasks, nothing else

yes, but not just wine - there is probably a case for Samba server and
NFSv4 to optionally request such behafvior).   Also we are likely to
see more cases where users want to run Samba over an NFS mount and
vice versa.

-- 
Thanks,

Steve
