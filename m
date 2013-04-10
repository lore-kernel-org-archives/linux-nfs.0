Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28158 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763884Ab3DJTd3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 15:33:29 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: NFS client hangs after server reboot
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130409190855.GB3800@fieldses.org>
Date: Wed, 10 Apr 2013 15:33:15 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Rick Macklem <rmacklem@uoguelph.ca>
Message-Id: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com>
References: <CACQjR_AH-AZDVLGKK8ZOVmkvQ-MEPuNn_y-Tu-ibrb6Rf7aC+Q@mail.gmail.com> <20130409190855.GB3800@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>, Bram Vandoren <brambi@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ Adding Rick Macklem ]

On Apr 9, 2013, at 3:08 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Apr 09, 2013 at 05:51:40PM +0200, Bram Vandoren wrote:
>> Hello,
>> we have a FreeBSD 9.1 fileserver and several clients running kernel
>> 3.8.4-102.fc17.x86_64. Everything works fine till we reboot the
>> server. A fraction (1/10) of the clients don't resume the NFS session
>> correctly. The server sends a NFS4ERR_STALE_STATEID. The client sends
>> a RENEW to the server but no SETCLIENTID. (this should be the correct
>> action from my very quick look at RFC 3530). After that the client
>> continues with a few READ call and the process starts again with the
>> NFS4ERR_STALE_STATEID response from the server. It generates a lot of
>> useless network traffic.
> 
>   0.003754  a.b.c.2 -> a.b.c.120 NFS 122 V4 Reply (Call In 49) READ Status: NFS4ERR_STALE_STATEID
>   0.003769  a.b.c.2 -> a.b.c.120 NFS 114 V4 Reply (Call In 71) RENEW
> 
> I don't normally use tshark, so I don't know--does the lack of a status
> on that second line indicate that the RENEW succeeded?
> 
> Assuming the RENEW is for the same clientid that the read stateid's are
> associated with--that's definitely a server bug.  The RENEW should be
> returning STALE_CLIENTID.

The server is returning NFS4_OK to that RENEW and we appear to be out of the server's grace period.  Thus we can assume that state recovery has already been performed following the server reboot, and a fresh client ID has been correctly established.  One possible explanation for NFS4ERR_STALE_STATEID is that the client skipped recovering these state IDs for some reason.

A full network capture in pcap format, started before the server reboot occurs, would be needed for us to analyze the issue properly.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




