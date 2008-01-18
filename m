From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 12:02:32 -0500
Message-ID: <1200675753.7781.32.camel@heimdal.trondhjem.org>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-3e24O53dDSM5+A3Kt+Ii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Fredrik Lindgren <fli-FpffG6+3qsA@public.gmane.org>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:38658 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759386AbYARRCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 12:02:42 -0500
In-Reply-To: <2a29d0a3c209d9488b0a3e8263c53e38-FpffG6+3qsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-3e24O53dDSM5+A3Kt+Ii
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, 2008-01-18 at 10:37 +0100, Fredrik Lindgren wrote:
> Hello,
> 
> I have been messing around with the excellent "iostat-ms" tool in
> an effort to understand what is going on with our machines that are
> showing lots of IOwait.
> 
> Below are two 15 second samples, the first one is taken during peak
> and the second one during the night. The obvious difference is in the
> "exe" field. Please excuse my ignorance, but what does this field mean?
> Where is this additional time spent? On the filer or in the NFS stack
> on the host?
> 
> stbnas1:/foo mounted on /misc/foo:
> 
>    op/s         rpc bklog
> 2364.60            0.96
> read:             ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
>                  43.267         659.624          15.246        0 (0.0%)          17.066         293.880
> write:            ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
>                  16.133          60.314           3.738        0 (0.0%)           3.868         255.074
> 
> stbnas1:/foo mounted on /misc/foo:
> 
>    op/s         rpc bklog
> 1446.07            0.26
> read:             ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
>                 105.200         189.155           1.798        0 (0.0%)           8.264           8.702
> write:            ops/s            Kb/s           Kb/op         retrans         avg RTT (ms)    avg exe (ms)
>                 105.067         297.774           2.834        0 (0.0%)           1.048           1.310

AFAICS the RTT (i.e. round trip time) is being reported as being of the
order of milliseconds in both cases, so the filer would not appear to be
responsible. The discrepancy has to be on the client side.

It would be interesting to see the 'rpc bklog' parameter in order to
confirm if the requests are being held up in the backlog queue.
Unfortunately, there appears to be a bug in iostat-ms: it appears to be
reading the 'number of requests in flight' where it should be reading
the 'length of backlog queue' parameter.
See if the attached patch doesn't help... (it also fixes a minor issue
of storing unsigned long long counters in the wrong type)

Cheers
  Trond


--=-3e24O53dDSM5+A3Kt+Ii
Content-Disposition: attachment; filename=iostat-ms.dif
Content-Type: text/x-patch; name=iostat-ms.dif; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- iostat-ms.orig	2007-10-15 07:27:24.000000000 -0400
+++ iostat-ms	2008-01-18 11:45:20.832558000 -0500
@@ -121,7 +121,8 @@
                 self.__rpc_data['rpcsends'] = int(words[4])
                 self.__rpc_data['rpcreceives'] = int(words[5])
                 self.__rpc_data['badxids'] = int(words[6])
-                self.__rpc_data['backlogutil'] = int(words[7])
+                self.__rpc_data['inflightsends'] = long(words[7])
+                self.__rpc_data['backlogutil'] = long(words[8])
             elif words[1] == 'tcp':
                 self.__rpc_data['port'] = words[2]
                 self.__rpc_data['bind_count'] = int(words[3])
@@ -131,7 +132,8 @@
                 self.__rpc_data['rpcsends'] = int(words[7])
                 self.__rpc_data['rpcreceives'] = int(words[8])
                 self.__rpc_data['badxids'] = int(words[9])
-                self.__rpc_data['backlogutil'] = int(words[10])
+                self.__rpc_data['inflightsends'] = long(words[10])
+                self.__rpc_data['backlogutil'] = long(words[11])
         elif words[0] == 'per-op':
             self.__rpc_data['per-op'] = words
         else:

--=-3e24O53dDSM5+A3Kt+Ii--

