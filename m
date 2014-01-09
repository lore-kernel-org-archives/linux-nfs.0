Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f45.google.com ([74.125.83.45]:39864 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaAIR1f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 12:27:35 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so1433579eek.18
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 09:27:34 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 4/5] NFSD/SUNRPC: Check rpc_xprt out of  xs_setup_bc_tcp
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140109162633.GB14308@fieldses.org>
Date: Thu, 9 Jan 2014 12:27:29 -0500
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C9F998C3-4A55-4714-926A-29440DF6F914@primarydata.com>
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com> <52CE7AE6.4010603@gmail.com> <20140109162633.GB14308@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 9, 2014, at 11:26, Dr Fields James Bruce <bfields@fieldses.org> wrote:

> On Thu, Jan 09, 2014 at 06:33:10PM +0800, Kinglong Mee wrote:
>> Besides checking rpc_xprt out of xs_setup_bc_tcp,
>> increase it's reference (it's important).
> 
> This sounds wrong to me: the presence of a backchannel can't prevent the
> client's connection from going away.  Instead, when the connection dies,
> any associated backchannels should be immediately destroyed.

Hi Bruce,

The right way to deal with this is to have knfsd shut down the rpc_client when it detects the TCP disconnection event. The xprt->count shouldn’t be an issue here: it has nothing to do with the socket connection state.

Cheers
  Trond