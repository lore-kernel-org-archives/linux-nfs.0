Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59323 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335Ab1DGOBN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 10:01:13 -0400
Subject: Re: Prioritizing readdirplus/getattr/lookup
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <747262.60831.qm@web65410.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 10:00:58 -0400
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
Message-Id: <56C8986A-3C8B-46C7-8C98-61C62FBC6BF8@oracle.com>
References: <747262.60831.qm@web65410.mail.ac4.yahoo.com>
To: Andrew Klaassen <clawsoon@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 6, 2011, at 3:25 PM, Andrew Klaassen wrote:

> I have, for now, hacked my way around my problem by splitting the server's uplink into two separate bonds.  This seems to have moderated the transaction rate of the HPC farm and allowed the "ls -l" calls to be served at an acceptable rate.

Have you created enough nfsd threads on your Linux NFS servers?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




