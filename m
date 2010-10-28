Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:54101 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab0J1M4v convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 08:56:51 -0400
Received: by ywk9 with SMTP id 9so1178647ywk.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 05:56:50 -0700 (PDT)
In-Reply-To: <4CC92A0C.20704@cea.fr>
References: <4CC92A0C.20704@cea.fr>
Date: Thu, 28 Oct 2010 08:56:50 -0400
Message-ID: <AANLkTikvHmPT-veXmJjwx8W56u0+1LKcxg96ewZ1c9T2@mail.gmail.com>
Subject: Re: Manpages about functions within libnfsidmap ?
From: Kevin Coffman <kwc@citi.umich.edu>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think the closest thing is the man page for the config file?

http://git.linux-nfs.org/?p=kwc/libnfsidmap.git;a=blob;f=idmapd.conf.5;h=9c7f1ae1bc5686142c6a8a0d71a5cb756daef212;hb=HEAD

There is, of course, the libnfsidmap source code as well...

K.C.


On Thu, Oct 28, 2010 at 3:45 AM, DENIEL Philippe <philippe.deniel@cea.fr> wrote:
> Hi,
>
> I wondered if documentations about the functions implemented in libnfsidmap
> exists. For now, I had a look at the rpc.idmapd's source code, but this is
> no "explicit" docs. Does such a thing exist ? (as manpages, plain text or
> any other human readable format)
>
>   Regards
>
>      Philippe
