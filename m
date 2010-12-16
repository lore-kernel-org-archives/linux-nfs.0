From: Ric Wheeler <ricwheeler@gmail.com>
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
Date: Thu, 16 Dec 2010 18:30:34 -0500
Message-ID: <4D0AA11A.2010307@gmail.com>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <20101216230524.GA16760@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, trond.myklebust@netapp.com,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:41748 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056Ab0LPXai (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:30:38 -0500
Received: by qwa26 with SMTP id 26so104551qwa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Dec 2010 15:30:37 -0800 (PST)
In-Reply-To: <20101216230524.GA16760@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/16/2010 06:05 PM, Christoph Hellwig wrote:
> Steve,
>
> I think it's totally out of place to try to put back large work on the
> whole nfs client for vendor interest in an absolute fringe feature.
>
> I think you should at least be a bit ashamed for even putting this
> forward.
>

This has nothing to do with shame or conspiracy, it has to do with doing changes 
in an orderly way so we can test and stabilize things in the upstream kernel.

Changing both at once is not good for upstream or distros  in my opinion,

Ric

