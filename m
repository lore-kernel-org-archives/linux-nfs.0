Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35697 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3FGOvl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jun 2013 10:51:41 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: NFS4+KRB5 trouble in Kernel >3.8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <kosc4c$9ar$1@ultimate100.geggus.net>
Date: Fri, 7 Jun 2013 10:51:29 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <CEF420B2-F649-40F6-B0D7-2187996A5493@oracle.com>
References: <koq2ie$gtu$1@ultimate100.geggus.net> <DBA14DEF-59CE-4068-B2B8-7F208F2EBA22@oracle.com> <kosc4c$9ar$1@ultimate100.geggus.net>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 7, 2013, at 6:19 AM, Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Perhaps you could try enabling debugging first to see where the hang occurs.
>> 
>> $ sudo rpcdebug -m nfs -s all
>> 
>> then add "-vvv" on the rpc.gssd command line.  Try your mount again, and look in /var/log/messages.
> 
> Client or server side or both?
> 
> As you have been talking about rpc.gssd I assume client side, right?

Your complaint was about mount problems, so I assumed client side, and did not visit the link you provided.

>From memory, the server equivalent is "-vv" or "-vvv" on the rpc.svcgssd command line, and

  $ sudo rpcdebug -m nfsd -s all

You might also enable debugging on mountd, see rpc.mountd(8).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




