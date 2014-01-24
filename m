Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:33931 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbaAXQLs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 11:11:48 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so3399325pbc.16
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 08:11:47 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs: handle servers that support either ALLOW or DENY ACE types.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140124142851.GA13421@us.ibm.com>
Date: Fri, 24 Jan 2014 09:11:43 -0700
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
References: <1390535453-15585-1-git-send-email-malahal@us.ibm.com> <979899AD-3AD6-4D89-B53F-1E30D4AB078B@primarydata.com> <20140124142851.GA13421@us.ibm.com>
To: Malahal Naineni <malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 24, 2014, at 7:28, Malahal Naineni <malahal@us.ibm.com> wrote:

> Trond Myklebust [trond.myklebust@primarydata.com] wrote:
>> 
>> On Jan 23, 2014, at 20:50, Malahal Naineni <malahal@us.ibm.com> wrote:
>> 
>>> Currently we support ACLs if the NFS server file system supports
>>> ALLOW and DENY ACE types. This patch makes the Linux client work with
>>> ACLs if the server supports either ALLOW or DENY ACE types.
>> 
>> According to RFC5661, the behaviour if you don’t have ALLOW aces is to deny all access. How does it make sense to accept that?
> 
> I have a server that only returned 'ALLOW' type support probably due to
> a bug!  There is nothing in the spec that said a server 'MUST' support
> 'ALLOW' and 'DENY' ACE types (RFC5661 does say 'SHOULD' though!). That
> was my reasoning to fix the client to be more liberal/lenient.
> 
> Can a server implicitly construct 'ALLOW' ACEs based on mode and not
> support explicitly setting such ACEs by a client? I am not too familiar
> with ACLs, if you think we should only check for 'ALLOW' support flag, I
> can re-spin the patch but I think it is better to be more lenient
> specially if it is not incorrect by being more lenient!

The way I read the spec, the default behaviour is to disallow access unless you have sufficient ALLOW aces for the behaviour that you want. The DENY aces are optional, and are there in order to explicitly deny a user or group a particular behaviour that they would otherwise be allowed due to some subsequent combination of ALLOW aces.

So, I accept that a server could function while only supporting ALLOW aces, but I don’t see how it could work at all with only DENY ace support.

Cheers
  Trond
--
Trond Myklebust
Linux NFS client maintainer

