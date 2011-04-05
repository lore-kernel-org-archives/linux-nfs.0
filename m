Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:46140 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab1DEA0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 20:26:52 -0400
Received: by pvg12 with SMTP id 12so1607682pvg.19
        for <linux-nfs@vger.kernel.org>; Mon, 04 Apr 2011 17:26:52 -0700 (PDT)
Message-ID: <4D9A61C9.1030900@panasas.com>
Date: Mon, 04 Apr 2011 17:26:49 -0700
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Andrew Klaassen <clawsoon@yahoo.com>, linux-nfs@vger.kernel.org
Subject: Re: Prioritizing readdirplus/getattr/lookup
References: <13701.83906.qm@web65411.mail.ac4.yahoo.com> <882887.75491.qm@web65412.mail.ac4.yahoo.com> <20110404230528.GA2624@merit.edu>
In-Reply-To: <20110404230528.GA2624@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-04 16:05, Jim Rees wrote:
> Andrew Klaassen wrote:
>
>   I've confirmed my earlier results using 2.6.37.5 on the server, though now
>   the results are closer to 10 times worse than the Netapp on similar
>   hardware rather than 100 times worse.
>   
>   A big improvement, but I'd still be interested to know if the server is
>   capable of the getattr/readdirplus/lookup versus read/write tradeoffs that
>   I'm looking for to bring "ls -l" speeds under load down to levels that
>   won't make my users yell at me.
>
> What would be nice is if we could add a new system call that would do
> roughly what the nfs4 readdir rpc does.  It would take a mask of requested
> file attributes, then return those attributes along with the directory
> entries.  This would help "ls -l" but would also help all those chatty new
> gnome/kde user interface things that love to stat every file in every
> directory.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Like this? :)
http://www.opengroup.org/platform/hecewg/uploads/40/10903/posix_io_readdir+.pdf

See this for discussion:
http://www.spinics.net/lists/linux-fsdevel/msg03276.html

And this for other ideas ;-)
http://www.opengroup.org/platform/hecewg/

Benny
