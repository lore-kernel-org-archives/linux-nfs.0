Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:44904 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab2DZRAi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 13:00:38 -0400
MIME-Version: 1.0
In-Reply-To: <18841.1335448056@redhat.com>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120419140625.17272.23303.stgit@warthog.procyon.org.uk>
	<CAH2r5mtHj6LnOcRDv37_S-tZmc42sTLwE8Z02+27XZbjEVzZfg@mail.gmail.com>
	<18841.1335448056@redhat.com>
Date: Thu, 26 Apr 2012 12:00:37 -0500
Message-ID: <CAH2r5muSz63aCJ56ExrXV2gmLQjmUhbnrpKT0RnRoXRQL3RtoQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] xstat: Ext4: Return extended attributes
From: Steve French <smfrench@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 8:47 AM, David Howells <dhowells@redhat.com> wrote:
> Steve French <smfrench@gmail.com> wrote:
>
>> This patch reminds me of a question on time stamps - how can an
>> application query the time granularity ie sb_s_time_gran for a mount
>> (e.g. 1 second for some file systems, 100 nanoseconds for cifs/smb2, 1
>> nanosecond for others etc.)
>
> Ummm...  In what context?  With the proposed xstat() interface it will be
> provided.

great (although I thought it would be "stat -f" property).


-- 
Thanks,

Steve
