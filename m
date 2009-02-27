Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:54602 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbZB0LOE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 06:14:04 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp.welcomes-you.com (Postfix) with ESMTP id CF29AC70002
	for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2009 12:13:59 +0100 (CET)
Received: from smtp.welcomes-you.com ([127.0.0.1])
	by localhost (smtp.welcomes-you.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0J8D9BXRuSrZ for <linux-nfs@vger.kernel.org>;
	Fri, 27 Feb 2009 12:13:59 +0100 (CET)
Received: from [10.117.96.106] (unknown [130.75.117.49])
	by smtp.welcomes-you.com (Postfix) with ESMTP id 4AEFAC70001
	for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2009 12:13:59 +0100 (CET)
Message-ID: <49A7CAF0.8000909@aei.mpg.de>
Date: Fri, 27 Feb 2009 12:13:52 +0100
From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: linux-nfs@vger.kernel.org
Subject: Re: [NFS] Write stalls over UDP and Gigabit
References: <200902271204.05099.Thorsten.Meinl@uni-konstanz.de>
In-Reply-To: <200902271204.05099.Thorsten.Meinl@uni-konstanz.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Thorsten,

Thorsten Meinl schrieb:
> Ich have to computer connected via Gigabit Ethernet via just one switch. I did 
> some experiments with dd from one computer to the other and got only rates of 
> about 10MB/s. Looking further at it, it looks quite strange: for the first 
> few seconds the transmission rate is at about 100MB/s which one would expect. 
> Then it drops down to about 20MB/s and then to only a few megabytes. Using 
> Wireshark I found out the following (this is a dump from the client that 
> writes the 10GB file):
[...]
> There is a 0.2s delay between packet 311 and 312 and it is totally uncleat to 
> me what could be the cause, as the reply for the last write call in 303 
> arrived in 311. So what is NFS waiting for (This situation occurs frequently 
> and I assume this is the cause of the very low throughput).
> The server storage system and the network cannot be the problem because using 
> sshfs I get rates of about 80MB/s and the bottleneck here is the CPU at the 
> client side.
> I also tried TCP and there the rates are slightly better but still do not 
> exceed ~20MB/s.
> Does anyone have an idea or any hints how I can debug this further? And yes, I 
> already tried the various suggestions in the FAQs like increasing receive 
> buffer sizes and such.

Just a blind guess. sshfs is using TCP while your NFS setup seems to be
UDP, so there might be the problem. Maybe your network is temporarily
congested and the egress switch is notifying the send to back off? There
should be a specific ethernet frame visible on the server side which I
guess wireshark should be able to see these pause frames
(http://en.wikipedia.org/wiki/Pause_frame)

Sorry if that's not helping much, but that's just my very first quarted
educated guess.

Cheers

Carsten
