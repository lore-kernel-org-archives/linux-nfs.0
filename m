Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34016 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaCSTld convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 15:41:33 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so8991159iec.8
        for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 12:41:33 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <5329E062.9030103@RedHat.com>
Date: Wed, 19 Mar 2014 15:41:30 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <34E0F031-281D-4409-8969-B0297EDA0EC4@primarydata.com>
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>		 <53286A9D.2020007@RedHat.com>		 <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>		 <53288146.4010601@RedHat.com>	 <1395168308.11244.3.camel@leira.trondhjem.org>	 <532897DE.6060204@RedHat.com>	 <EB317FC8-D521-4D80-98D7-FA48B0B9AF0C@primarydata.com>	 <5329900C.3040200@RedHat.com>	 <DAF0940D-107D-4251-B00A-DE829A31B36E@primarydata.com>	 <5329A4B3.20601@RedHat.com>	 <0C0E5EE2-E7BD-4BE3-961F-3B632B45F026@primarydata.com>	 <5329CF7C.7090308@RedHat.com> <1395250160.7168.1.camel@leira.trondhjem.org> <5329E062.9030103@RedHat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 19, 2014, at 14:22, Steve Dickson <SteveD@redhat.com> wrote:
> 
> What's going on is-ECONNREFUSED is being seen in call_connect_status() 
> and the task is not a soft connection. So call_timeout() is call which 
> eventual times out the mount… 

This is what is confusing me. I’d expect that the rpc_ping() would be the first thing to be sent on the wire by rpc_create(), and that ping should normally have the RPC_SOFTCONN flag set.

> So just for fun I make the SETCLIENTID rpc soft, but for some
> reason that didn't work either... I thought for sure it would... 
> 
> steved.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

