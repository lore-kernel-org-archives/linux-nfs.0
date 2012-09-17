Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.scalarmail.ca ([98.158.95.75]:46652 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab2IQOEM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2012 10:04:12 -0400
Date: Mon, 17 Sep 2012 10:04:05 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: kernel BUG at fs/nfs/idmap.c:684!
Message-ID: <20120917140405.GA19032@elliptictech.com>
References: <20120914192056.GA15530@elliptictech.com>
 <50571F51.9080100@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50571F51.9080100@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Bryan,

On 2012-09-17 09:02 -0400, Bryan Schumaker wrote:
> Two questions:
> 1) How sure are you that you're using v3?  Make sure you're using the
> 'vers=3' mount option.  I'm not sure which version of nfs-utils Debian
> uses, but recent versions set v4 as the default.

I looked in /proc/mounts and all of them had vers=3.  But...

> 2) Can you try Linux 3.5.4?  Patches for the idmapper issue have
> already been accepted.

...indeed, Linux 3.5.4 seems to be working.  Moreover, if I look at
/proc/mounts now I do in fact see a single line with vers=4.  I guess
the v4 mount is what crashed so it didn't show up in the list.

Thanks,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

