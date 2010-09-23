Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:45629 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab0IWVbI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 17:31:08 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 0ED86DF4
	for <linux-nfs@vger.kernel.org>; Thu, 23 Sep 2010 23:31:07 +0200 (MEST)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 09CFADF1
	for <linux-nfs@vger.kernel.org>; Thu, 23 Sep 2010 23:31:06 +0200 (MEST)
Content-Type: text/plain; charset=US-ASCII
Subject: RE: question about nfs41 features
Date: Thu, 23 Sep 2010 23:31:06 +0200
Message-ID: <2CF5F37A49FC1743A7940A3FA6E0A8FB050FBDA5@ADXV1.win.desy.de>
References: <AANLkTinvrHsQmcLCpt99dE1nU0md8zfwsh4vP8JRBJT6@mail.gmail.com>
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "Olga Kornievskaia" <aglo@citi.umich.edu>,
        "linux-nfs" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



-----Original Message-----
From: linux-nfs-owner@vger.kernel.org on behalf of Olga Kornievskaia
Sent: Thu 9/23/2010 20:30
To: linux-nfs
Subject: question about nfs41 features
 
I would greatly appreciate it I can get a reply from NFS41 server
implementers out there on the subject of whether or not the following
feature are (a) currently implemented by your server, (b) will be
implemented soon (1year), (c) having interest in being implemented
within the next few years and (d) are so low in priority that could be
said: will never be implemented.


d) volatile handles
c) named attributes
c) directory delegations
d) SSV
a? if not - have to be fixed) trunking (session or clientid)
a, but switched off as linux client can't do that) segmented file layouts

b) recall of file layouts
a/b) cb_notify_deviceid
c) cb_getattr
c) cb_recall_slot
d) cb_notify_lock

Thank you.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

