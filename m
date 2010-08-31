Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40880 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572Ab0HaUaW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 16:30:22 -0400
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100831110024.68e8877d@notabene>
Date: Tue, 31 Aug 2010 16:29:59 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <4B6431AA-0FFD-4FE9-9DF4-4AF7D2B2AD20@oracle.com>
References: <20100826120635.4c3157bc@notabene> <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com> <20100830103025.70d09ec8@notabene> <BC2D2164-0836-4DAC-99C5-C7BE23D3B163@oracle.com> <20100831110024.68e8877d@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 30, 2010, at 9:00 PM, Neil Brown wrote:

> Two observations I've made while exploring which are only tangential to the
> current issue:
> 
> 1/ if I give an invalid proto name
>          mount -o proto=fred .....
>    the mount command fails (as it should) but gives no error message.

I was not able to reproduce this.  I get an appropriate error message from mount.nfs when built either with TI-RPC or without.  I'm using the latest upstream nfs-utils + my mountd patches.

-- 
chuck[dot]lever[at]oracle[dot]com




