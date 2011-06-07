Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39300 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948Ab1FGBLN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 21:11:13 -0400
Subject: Re: Question on portmapper source
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DED6DC8.8020500@candelatech.com>
Date: Mon, 6 Jun 2011 21:11:00 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <7B1787E7-75DC-4CBB-86DA-FAA1B0366B00@oracle.com>
References: <4DED6DC8.8020500@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 6, 2011, at 8:16 PM, Ben Greear wrote:

> What is the official upstream project that contains the portmapper
> source?

Do you want pormapper or rpcbind?  The newer rpcbind actually allows RPC services to register at specific addresses, but the legacy portmapper does not.

> Also, the mount.nfs package, as I'll probably need to modify that
> as well...

mount.nfs is in nfs-utils.

> I am going to try to allow portmapper to bind to a particular
> source IP when making outbound requests....

I don't understand.  portmapper, as an RPC service, receives incoming requests.  But we don't use the rpcbind CALLIT procedure on Linux, thus it doesn't make outbound requests.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




