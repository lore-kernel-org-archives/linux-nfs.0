From: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>
Subject: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 10:37:55 +0100
Message-ID: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailfe11.swip.net ([212.247.155.65]:40013 "EHLO swip.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751017AbYARKiA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 05:38:00 -0500
Received: from [192.71.219.1] (account fli-FpffG6+3qsA@public.gmane.org)
  by mailbe03.swip.net (CommuniGate Pro IMAP 5.1.13)
  with XMIT id 90184203 for linux-nfs@vger.kernel.org; Fri, 18 Jan 2008 10:37:56 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I have been messing around with the excellent "iostat-ms" tool in
an effort to understand what is going on with our machines that are
showing lots of IOwait.

Below are two 15 second samples, the first one is taken during peak
and the second one during the night. The obvious difference is in the
"exe" field. Please excuse my ignorance, but what does this field mean?
Where is this additional time spent? On the filer or in the NFS stack
on the host?

stbnas1:/foo mounted on /misc/foo:

   op/s         rpc bklog
2364.60            0.96
read:             ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
                 43.267         659.624          15.246        0 (0.0%)          17.066         293.880
write:            ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
                 16.133          60.314           3.738        0 (0.0%)           3.868         255.074

stbnas1:/foo mounted on /misc/foo:

   op/s         rpc bklog
1446.07            0.26
read:             ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
                105.200         189.155           1.798        0 (0.0%)           8.264           8.702
write:            ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
                105.067         297.774           2.834        0 (0.0%)           1.048           1.310


Regards,
  Fredrik Lindgren




