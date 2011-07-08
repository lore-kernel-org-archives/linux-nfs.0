Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab1GHAUQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2011 20:20:16 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19990.19772.54549.203398@regina.usersys.redhat.com>
Date: Fri, 8 Jul 2011 10:20:12 +1000
From: Max Matveev <makc@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS/TCP timeout sequence
In-Reply-To: <1310046439.3863.30.camel@lade.trondhjem.org>
References: <19989.27202.793003.725608@regina.usersys.redhat.com>
	<1310046439.3863.30.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 07 Jul 2011 09:47:19 -0400, Trond Myklebust wrote:

 TM> On Thu, 2011-07-07 at 18:11 +1000, Max Matveev wrote: 

 TM> Sigh... Firstly, 2 second timeouts are complete lunacy when using a
 TM> protocol that guarantees reliable delivery, such as TCP does. Anyone who
 TM> tries it deserves exactly what they get: poor unreliable performance.

2 seconds is besides the point - I'm not going to wait for 28 minutes
(timeout=600,retrans=7) when doing timeout testing just to prove that
it does not work.

 TM> Secondly, the _other_ fix for this problem is to fix the documentation.

I can live with that too.

max
