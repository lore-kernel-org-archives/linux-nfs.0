Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-3.desy.de ([131.169.56.86]:62230 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab1J1LYs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2011 07:24:48 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 30D8E143E
	for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2011 12:55:01 +0200 (MEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 1DEC51352
	for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2011 12:55:01 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta05701c54783a961601294@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 28 Oct 2011 12:55:01 +0200
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id F1B153E901
	for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2011 12:55:00 +0200 (MEST)
Message-ID: <4EAA893F.2020107@desy.de>
Date: Fri, 28 Oct 2011 12:51:43 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Reply-To: tigran.mkrtchyan@desy.de
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pNFS instance @ amazon.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dear (p)NFS developers,

as promised at BAT I started an instance of our NFS implementation
on amazon EC2.

ec2-184-72-157-25.compute-1.amazonaws.com : MDS + DS on port 2052.

export: /

nfsv4.1+pnfs only

It is a microedition VM with a small disk. Currently name IP
is assigned dynamically on restart.

According to amazon, it runs in US East (Virginia) region.

This is just an experiment :). Let see how many people will test that 
(and how much it will cost  me :) )


Regards,
    Tigran.
